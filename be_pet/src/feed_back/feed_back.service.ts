import { HttpException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Feedback } from './entities/feed_back.entity';
import { Brackets, Repository } from 'typeorm';

import { Product } from 'src/product/entities/product.entity';

import { CreateFeedbackDto } from './dtos/create_feed-back.dto';
import { FeedbackStatusEnum } from './constants/status_feedback.constant';
import { UpdateFeedbackDto } from './dtos/update_feed-back.dto';
import { ImageService } from 'src/image/image.service';
import {
  ErrorCodeFeedback,
  ErrorMessageFeedback,
} from './constants/error-code-feedback.constant';
import { FeedbackFilterType } from './interfaces/feedback.filter-type.interface';

import { SORT_BY_FEEDBACK } from './constants/feedback.sort-by.constant';
import { User } from 'src/user/entities/user.entity';
import {
  ErrorCodeProduct,
  ErrorMessageProduct,
} from 'src/product/constants/error-code-product.constant';
import { ProductVariant } from 'src/product_variant/entites/product-variant.entity';
import {
  ErrorCodeProductVariant,
  ErrorMessageProductvariant,
} from 'src/product_variant/constants/error-code-product-variant.constant';

@Injectable()
export class FeedBackService {
  constructor(
    @InjectRepository(Feedback)
    private readonly feedbackRepository: Repository<Feedback>,
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
    private readonly imageService: ImageService,
    @InjectRepository(ProductVariant)
    private readonly productVariantRepository: Repository<ProductVariant>,
  ) {}

  private async checkFeedbackId(id: number): Promise<Feedback> {
    const feedback = await this.feedbackRepository.findOne({
      where: { id: id },
    });
    if (!feedback) {
      throw new HttpException(
        ErrorMessageFeedback[1401],
        ErrorCodeFeedback.FEEDBACK_NOT_FOUND,
      );
    }

    return feedback;
  }

  private async checkProductId(productId: number): Promise<Product> {
    const product = await this.productRepository.findOne({
      where: { id: productId },
    });
    if (!product) {
      throw new HttpException(
        ErrorMessageProduct[601],
        ErrorCodeProduct.PRODUCT_NOT_FOUND,
      );
    }
    return product;
  }

  private async checkProductVariantId(
    productVariantId: number,
  ): Promise<ProductVariant> {
    const productVariant = await this.productVariantRepository.findOne({
      where: { id: productVariantId },
      relations: ['product', 'image'],
    });

    if (!productVariant) {
      throw new HttpException(
        ErrorMessageProductvariant[701],
        ErrorCodeProductVariant.PRODUCT_VARIANT_NOT_FOUND,
      );
    }

    return productVariant;
  }
  async create(data: CreateFeedbackDto): Promise<any> {
    const feedback = await this.feedbackRepository.create({
      user_id: data.user_id,
      product_variant_id: data.product_variant_id,
      status: FeedbackStatusEnum.PENDING,
      order_id: data.order_id,
    });
    await this.feedbackRepository.save(feedback);

    return await this.getOneFeedbackOption(feedback);
  }

  async update(
    id: number,
    data: UpdateFeedbackDto,
    feedbackImage?: Express.Multer.File,
  ): Promise<any> {
    const feedback = await this.checkFeedbackId(id);
    if (feedback.status == FeedbackStatusEnum.REVIEWED) {
      throw new HttpException(
        ErrorMessageFeedback[1402],
        ErrorCodeFeedback.FEEDBACK_HAS_BEEN_UPDATED,
      );
    }
    const productVariant = await this.checkProductVariantId(
      feedback.product_variant_id,
    );

    const product = await this.checkProductId(productVariant.product_id);

    feedback.rating = data.rating;
    if (feedbackImage) {
      const imagePath = await this.imageService.upload(feedbackImage);
      feedback.image = imagePath;
    }
    feedback.comment =
      data.comment !== undefined ? data.comment : feedback.comment;
    feedback.status = FeedbackStatusEnum.REVIEWED;
    await this.feedbackRepository.save(feedback);
    console.log(feedback);
    const updatedFeedbacks = await this.feedbackRepository.find({
      where: {
        product_variant_id: feedback.product_variant_id,
        status: FeedbackStatusEnum.REVIEWED,
      },
    });
    const totalRating = updatedFeedbacks.reduce(
      (acc, curr) => acc + curr.rating,
      0,
    );
    const averageRating = totalRating / updatedFeedbacks.length;

    product.rating = averageRating;
    await this.productRepository.save(product);

    return feedback;
  }

  async getList({
    user,
    filter,
  }: {
    user?: User;
    filter: FeedbackFilterType;
  }): Promise<any> {
    let itemsPerPage: number = Number(filter.items_per_page) || 10;
    if (itemsPerPage > 50) {
      itemsPerPage = 50;
    }
    const page: number = filter.page || 1;
    //const search: string = filter.search || '';
    const status: string = filter.status || '';
    const skip = page - 1 ? (page - 1) * itemsPerPage : 0;
    let sort_by: string = filter.sort_by || 'created_at';
    const order_by = filter.order_by?.toLowerCase() === 'asc' ? 'ASC' : 'DESC';
    if (!SORT_BY_FEEDBACK.includes(sort_by)) {
      sort_by = 'created_at';
    }

    const product_id: number = filter.product_id || -1;

    let productVariantIds: number[] = [];
    if (product_id !== -1) {
      const productVariantIdsArray = await this.productVariantRepository.find({
        where: { product_id },
        select: ['id'],
      });
      productVariantIds = productVariantIdsArray.map((item) => item.id);
    }

    const order_id: number = filter.order_id || -1;

    const query = this.feedbackRepository.createQueryBuilder('feedback');
    query.andWhere(
      new Brackets((qb) => {
        if (user && user.role == 'user') {
          qb.andWhere('feedback.user_id = :user_id', { user_id: user.id });
        }
        if (status) {
          qb.andWhere('feedback.status LIKE :status', {
            status: `%${status}%`,
          });
        }

        if (productVariantIds.length > 0) {
          qb.andWhere(
            'feedback.product_variant_id IN (:...productVariantIds)',
            { productVariantIds: productVariantIds }, // 수정된 부분
          );
        }

        if (order_id !== -1) {
          qb.andWhere('feedback.order_id = :order_id', { order_id });
        }
      }),
    );
    query.orderBy(`feedback.${sort_by}`, order_by);
    query.skip(skip);
    query.take(itemsPerPage);
    const [data, total] = await query.getManyAndCount();
    const feedbackOptions = await this.getListFeedbackOption(data);
    return {
      feedbacks: feedbackOptions,
      total: total,
    };
  }

  async getOneFeedbackOption(feedback: Feedback): Promise<any> {
    return {
      id: Number(feedback.id),
      user_id: Number(feedback.user_id),
      product_variant_id: Number(feedback.product_variant_id),
      order_id: Number(feedback.order_id),
      status: feedback.status,
      rating: feedback.rating,
      comment: feedback.comment,
      image: feedback.image,
    };
  }

  async getListFeedbackOption(feedbacks: Feedback[]): Promise<any> {
    return await Promise.all(
      feedbacks.map(
        async (feedback) => await this.getOneFeedbackOption(feedback),
      ),
    );
  }
}
