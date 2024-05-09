import { HttpException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Product } from './entities/product.entity';
import { Brackets, Repository } from 'typeorm';
import { Image } from 'src/image/entities/image.entity';
import { ImageService } from 'src/image/image.service';
import { CreateProductDto } from './dtos/create-product.dto';
import { Category } from 'src/category/entities/category.entity';
import {
  ErrorCodeCategory,
  ErrorMessageCategory,
} from 'src/category/constants/error-code-category.constant';
import {
  ErrorCodeProduct,
  ErrorMessageProduct,
} from './constants/error-code-product.constant';
import { UpdateProductDto } from './dtos/update-product.dto';
import { ProductFilterType } from './interface/product.filter-type.interface';
import { SORT_BY_PRODUCT } from './constants/product.sort-by.constant';

@Injectable()
export class ProductService {
  constructor(
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,

    private readonly imageService: ImageService,
    @InjectRepository(Category)
    private readonly categoryRepositpory: Repository<Category>,
  ) {}

  private async checkCategoryId(id: number): Promise<void> {
    const category = await this.categoryRepositpory.findOne({
      where: { id: id },
    });
    if (!category) {
      throw new HttpException(
        ErrorMessageCategory[402],
        ErrorCodeCategory.CATEGORY_NOT_FOUND,
      );
    }
  }

  private async checkNameProduct(name: string): Promise<void> {
    const product = await this.productRepository.findOne({
      where: { name: name },
    });
    if (product) {
      throw new HttpException(
        ErrorMessageProduct[602],
        ErrorCodeProduct.PRODUCT_NAME_EXISTS,
      );
    }
  }

  private async checkProductId(id: number): Promise<Product> {
    const product = await this.productRepository.findOne({ where: { id: id } });
    if (!product) {
      throw new HttpException(
        ErrorMessageProduct[601],
        ErrorCodeProduct.PRODUCT_NOT_FOUND,
      );
    }
    return product;
  }

  async create(
    data: CreateProductDto,
    productImage: Express.Multer.File,
  ): Promise<any> {
    await this.checkCategoryId(data.category_id);
    await this.checkNameProduct(data.name);
    const imgId = await this.imageService.createImageId(productImage);
    const product = await this.productRepository.create({
      name: data.name,
      description: data.description || 'Chưa có mô tả cho sản phẩm này',
      ingredient:
        data.ingredient || 'Chưa có hướng dẫn sử dụng cho sản phẩm này',
      origin: data.origin || 'Chưa có dữ liệu xuất xứ cho sản phẩm này',
      unit: data.unit || 'Tuỳ vào phân loại',
      brand: data.brand || 'Chưa có thương hiệu cho sản phẩm này',
      category_id: data.category_id,
      image_id: imgId,
      is_best_seller: 0,
      rating: 0,
      sold: 0,
    });
    return await this.productRepository.save(product);
  }

  async update(
    id: number,
    data: UpdateProductDto,
    productImage?: Express.Multer.File,
  ): Promise<any> {
    const product = await this.checkProductId(id);
    if (data.category_id) {
      await this.checkCategoryId(data.category_id);
      product.category_id = data.category_id;
    }
    if (data.name && data.name != product.name) {
      await this.checkNameProduct(data.name);
      product.name = data.name;
    }
    if (productImage) {
      const idImage = await this.imageService.createImageId(productImage);
      product.image_id = idImage;
    }

    product.is_best_seller =
      Number(data.is_best_seller) !== null &&
      Number(data.is_best_seller) !== undefined &&
      !isNaN(Number(data.is_best_seller))
        ? Number(data.is_best_seller)
        : Number(product.is_best_seller);

    product.description =
      data.description != undefined ? data.description : product.description;

    product.brand = data.brand != undefined ? data.brand : product.brand;

    product.unit = data.unit != undefined ? data.unit : product.unit;

    product.ingredient =
      data.ingredient != undefined ? data.ingredient : product.ingredient;

    product.origin = data.origin != undefined ? data.origin : product.origin;

    return await this.productRepository.save(product);
  }

  async getDetail(id: number): Promise<any> {
    const query = this.productRepository.createQueryBuilder('product');
    query.leftJoinAndSelect('product.image', 'imageProduct');
    query.leftJoinAndSelect('product.product_variants', 'product_variants');
    query.leftJoinAndSelect('product_variants.image', 'imageVariant');
    query.andWhere(
      new Brackets((qb) => {
        qb.andWhere('product.id = :id', { id });
      }),
    );
    const data = await query.getOne();
    if (!data) {
      throw new HttpException(
        ErrorMessageProduct[601],
        ErrorCodeProduct.PRODUCT_NOT_FOUND,
      );
    }
    return await this.getOneProductOption(data);
  }

  async getProductByProductVariantId(productVariantId: number): Promise<any> {}

  async getList(filter: ProductFilterType): Promise<any> {
    let itemsPerPage: number = Number(filter.items_per_page) || 10;
    if (itemsPerPage > 50) {
      itemsPerPage = 50;
    }
    console.log(filter);
    const page: number = filter.page || 1;
    const search: string = filter.search || '';
    const skip = page - 1 ? (page - 1) * itemsPerPage : 0;
    let sort_by: string = filter.sort_by || 'created_at';
    const order_by = filter.order_by?.toLowerCase() === 'desc' ? 'DESC' : 'ASC';
    if (!SORT_BY_PRODUCT.includes(sort_by)) {
      sort_by = 'created_at';
    }

    const category_id: number = filter.category_id || -1;

    const query = this.productRepository.createQueryBuilder('product');

    if (search) {
      query.andWhere(
        new Brackets((qb) => {
          qb.where('product.name ILIKE :search', {
            search: `%${search}%`,
          }).orWhere('product.description ILIKE :search', {
            search: `%${search}%`,
          });
        }),
      );
    }

    if (category_id !== -1) {
      query.andWhere(
        new Brackets((qb) => {
          if (category_id) {
            qb.andWhere('product.category_id = :category_id', { category_id });
          }
        }),
      );
    }

    query.leftJoinAndSelect('product.image', 'imageProduct');
    query.leftJoinAndSelect('product.product_variants', 'product_variants');
    query.leftJoinAndSelect('product_variants.image', 'imageVariant');
    query.orderBy(`product.${sort_by}`, order_by);
    query.skip(skip);
    query.take(itemsPerPage);

    const [data, total] = await query.getManyAndCount();
    const productOptions = await this.getListProductOption(data);
    return {
      products: productOptions,
      total: total,
    };
  }

  async countProduct(search: string): Promise<any> {
    const query = this.productRepository.createQueryBuilder('product');
    console.log(search);
    if (search) {
      query.andWhere(
        new Brackets((qb) => {
          qb.where('product.name ILIKE :search', {
            search: `%${search}%`,
          }).orWhere('product.description ILIKE :search', {
            search: `%${search}%`,
          });
        }),
      );
    }
    const [data, total] = await query.getManyAndCount();

    return {
      total: total,
    };
  }

  async getTop5SellingProducts(): Promise<any> {
    try {
      const top5Products = await this.productRepository
        .createQueryBuilder('product')
        .select(['product.name AS product_name', 'product.sold']) // Select specific fields
        .orderBy('product.sold', 'DESC')
        .take(5)
        .getRawMany(); // Use getRawMany for custom response shape
      return top5Products;
    } catch (error) {
      throw new HttpException(
        ErrorMessageProduct[603],
        ErrorCodeProduct.ERROR_GET_TOP_SELLING,
      );
    }
  }

  async getOneProductOption(product: Product): Promise<any> {
    return {
      id: product.id,
      name: product.name,
      category_id: product.category_id,
      description: product.description || 'Chưa có mô tả cho sản phẩm này',
      is_best_seller: product.is_best_seller,
      rating: product.rating,
      sold: product.sold,
      image_path: product.image.path,
      ingredient: product.ingredient || 'Thành phần xem chi tiết trên bao bì',
      origin: product.origin || ' Xuất xứ xem trên bao bì sản phẩm',
      brand: product.brand || 'Thương hiệu xem trên bao bì sản phẩm',
      unit: product.unit || 'Tuỳ Size',
      product_variant: product.product_variants.map((productVariant) => ({
        id: productVariant.id,
        name: productVariant.name,
        product_code: productVariant.product_code,
        product_id: productVariant.product_id,
        price: Number(productVariant.price),
        weight: Number(productVariant.weight),
        discount_rate: productVariant.discount_rate,
        inventory: productVariant.inventory,
        image_path: productVariant.image.path,
      })),
    };
  }

  private async getListProductOption(products: Product[]): Promise<any> {
    const productOption = await Promise.all(
      products.map((product) => this.getOneProductOption(product)),
    );

    return productOption;
  }
}
