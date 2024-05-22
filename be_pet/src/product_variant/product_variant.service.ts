import { HttpException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { ProductVariant } from './entites/product-variant.entity';
import { Repository } from 'typeorm';
import { Product } from 'src/product/entities/product.entity';
import {
  ErrorCodeProduct,
  ErrorMessageProduct,
} from 'src/product/constants/error-code-product.constant';
import { CreateProductVariantDto } from './dtos/create-product-variant.dto';
import {
  ErrorCodeProductVariant,
  ErrorMessageProductvariant,
} from './constants/error-code-product-variant.constant';
import { ImageService } from 'src/image/image.service';
import { UpdateProductVariantDto } from './dtos/update-product-variant.dto';
import { ProductService } from 'src/product/product.service';

@Injectable()
export class ProductVariantService {
  constructor(
    @InjectRepository(ProductVariant)
    private readonly productVariantRepository: Repository<ProductVariant>,
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
    private readonly imageService: ImageService,
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

  private async checkProductCode(product_code: string): Promise<void> {
    const productVariant = await this.productVariantRepository.findOne({
      where: { product_code: product_code },
    });
    if (productVariant) {
      throw new HttpException(
        ErrorMessageProductvariant[702],
        ErrorCodeProductVariant.PRODUCT_CODE_EXISTS,
      );
    }
  }

  private async checkProductVariantName(
    product_id: number,
    name: string,
  ): Promise<void> {
    const productVariant = await this.productVariantRepository.findOne({
      where: {
        product_id: product_id,
        name: name,
      },
    });
    if (productVariant) {
      throw new HttpException(
        ErrorMessageProductvariant[703],
        ErrorCodeProductVariant.PRODUCT_VARIANT_NAME_EXISTS,
      );
    }
  }

  async checkProductVariantId(id: number): Promise<ProductVariant> {
    const productVariant = await this.productVariantRepository.findOne({
      where: { id: id },
    });
    if (!productVariant) {
      throw new HttpException(
        ErrorMessageProductvariant[701],
        ErrorCodeProductVariant.PRODUCT_VARIANT_NOT_FOUND,
      );
    }

    return productVariant;
  }

  async getProductByProductvariantId(productVariantId: number): Promise<any> {
    const productVariant = await this.checkProductVariantId(productVariantId);
    await this.checkProductId(productVariant.product_id);
    return await this.productService.getDetail(productVariant.product_id);
  }

  async create(
    data: CreateProductVariantDto,
    productImage: Express.Multer.File,
  ): Promise<any> {
    console.log(data);
    console.log(productImage);
    await this.checkProductId(data.product_id);
    if (data.product_code) {
      await this.checkProductCode(data.product_code);
    }
    await this.checkProductVariantName(data.product_id, data.name);

    const imgId = await this.imageService.createImageId(productImage);

    const productVariant = await this.productVariantRepository.create({
      name: data.name,
      product_code: data.product_code || null,
      product_id: data.product_id,
      price: Number(data.price),
      weight: Number(data.weight),
      discount_rate: data.discount_rate || 0,
      inventory: data.inventory,
      image_id: imgId,
    });

    console.log('=================', productVariant);
    return await this.productVariantRepository.save(productVariant);
  }

  async update(
    id: number,
    data: UpdateProductVariantDto,
    productImage?: Express.Multer.File,
  ): Promise<any> {
    const productVariant = await this.checkProductVariantId(id);
    if (data.name && data.name != productVariant.name) {
      await this.checkProductVariantName(productVariant.product_id, data.name);
      productVariant.name = data.name;
    }
    if (productImage) {
      const imgId = await this.imageService.createImageId(productImage);
      productVariant.image_id = imgId;
    }
    if (data.product_code && data.product_code != productVariant.product_code) {
      await this.checkProductCode(data.product_code);
      productVariant.product_code = data.product_code;
    }
    if (data.inventory) {
      productVariant.inventory += Number(data.inventory);
    }

    productVariant.price =
      Number(data.price) !== null &&
      Number(data.price) !== undefined &&
      !isNaN(Number(data.price))
        ? Number(data.price)
        : Number(productVariant.price);

    productVariant.weight =
      Number(data.weight) !== null &&
      Number(data.weight) !== undefined &&
      !isNaN(Number(data.weight))
        ? Number(data.weight)
        : Number(productVariant.weight);

    productVariant.discount_rate =
      Number(data.discount_rate) !== null &&
      Number(data.discount_rate) !== undefined &&
      !isNaN(Number(data.discount_rate))
        ? Number(data.discount_rate)
        : Number(productVariant.discount_rate);

    return await this.productVariantRepository.save(productVariant);
  }

  async remove(id: number): Promise<any> {
    const productVariant = await this.checkProductVariantId(id);
    await this.productVariantRepository.softDelete(id);
    return {
      message: 'Xoá phân loại thành công',
      productVariant,
    };
  }
}
