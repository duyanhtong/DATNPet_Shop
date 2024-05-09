import { HttpException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { WishList } from './entities/wish-list.entity';
import { Brackets, Repository } from 'typeorm';
import { Product } from 'src/product/entities/product.entity';
import { CreateWishListDto } from './dtos/create-wish_list.dto';
import {
  ErrorCodeProduct,
  ErrorMessageProduct,
} from 'src/product/constants/error-code-product.constant';
import { User } from 'src/user/entities/user.entity';
import {
  ErrorCodeWishList,
  ErrorMessageWishList,
} from './constants/error-code-user.constant';
import { WishListFilterType } from './interfaces/wish-list.filter-type.interface';
import { SORT_BY_WISH_LIST } from './constants/product.sort-by.constant';
import { ProductService } from 'src/product/product.service';

@Injectable()
export class WishListService {
  constructor(
    @InjectRepository(WishList)
    private readonly wishListRepository: Repository<WishList>,
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
    private readonly productService: ProductService,
  ) {}

  private async checkProductId(id: number): Promise<void> {
    const product = await this.productRepository.findOne({ where: { id: id } });
    if (!product) {
      throw new HttpException(
        ErrorMessageProduct[601],
        ErrorCodeProduct.PRODUCT_NOT_FOUND,
      );
    }
  }

  async checkExistWishList(userId: number, productId: number): Promise<any> {
    const wishList = await this.wishListRepository.findOne({
      where: { user_id: userId, product_id: productId },
    });
    if (!wishList) {
      return null;
    }

    return wishList.id;
  }

  async create(user: User, data: CreateWishListDto): Promise<any> {
    const wishListId = await this.checkExistWishList(user.id, data.product_id);
    if (wishListId) {
      await this.remove(user.id, data.product_id);
      return {
        message: 'Đã xoá sản phẩm khỏi danh sách yêu thích!',
      };
    } else {
      await this.checkProductId(data.product_id);
      const wishList = await this.wishListRepository.create({
        user_id: user.id,
        product_id: data.product_id,
      });
      await this.wishListRepository.save(wishList);
      return {
        message: 'Thêm thành công vào danh sách yêu thích!',
      };
    }
  }

  async remove(userId: number, productId: number): Promise<void> {
    const wishListId = await this.checkExistWishList(userId, productId);
    if (!wishListId) {
      throw new HttpException(
        ErrorMessageWishList[1001],
        ErrorCodeWishList.WISH_LIST_NOT_FOUND,
      );
    }
    await this.wishListRepository.delete(wishListId);
  }

  async getList(user: User, filter: WishListFilterType): Promise<any> {
    let itemsPerPage: number = Number(filter.items_per_page) || 10;
    if (itemsPerPage > 50) {
      itemsPerPage = 50;
    }
    const page: number = filter.page || 1;
    const search: string = filter.search || '';
    const skip = page - 1 ? (page - 1) * itemsPerPage : 0;
    let sort_by: string = filter.sort_by || 'created_at';
    const order_by = filter.order_by?.toLowerCase() === 'desc' ? 'DESC' : 'ASC';
    if (!SORT_BY_WISH_LIST.includes(sort_by)) {
      sort_by = 'created_at';
    }

    const user_id = user.id;

    const query = this.wishListRepository.createQueryBuilder('wish_list');
    query.andWhere(
      new Brackets((qb) => {
        qb.where('wish_list.user_id  =:user_id', { user_id });
      }),
    );

    query.leftJoinAndSelect('wish_list.product', 'product');
    query.leftJoinAndSelect('product.image', 'imageProduct');
    query.leftJoinAndSelect('product.product_variants', 'product_variants');
    query.leftJoinAndSelect('product_variants.image', 'imageVariant');
    query.orderBy(`wish_list.${sort_by}`, order_by);
    query.skip(skip);
    query.take(itemsPerPage);

    const [data, total] = await query.getManyAndCount();
    const wishListOptions = await this.getListWishListOption(data);

    return {
      wishLists: wishListOptions,
      total,
    };
  }

  private async getOneWishListOption(wishList: WishList): Promise<any> {
    return {
      id: wishList.id,
      product: await this.productService.getOneProductOption(wishList.product),
    };
  }

  private async getListWishListOption(wishLists: WishList[]): Promise<any> {
    const wishListOption = await Promise.all(
      wishLists.map((wishList) => this.getOneWishListOption(wishList)),
    );
    return wishListOption;
  }
}
