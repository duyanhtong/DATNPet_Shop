import { HttpException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { CartItem } from './entities/cart-item.entity';
import { Brackets, Repository } from 'typeorm';
import { Product } from 'src/product/entities/product.entity';
import { ProductVariant } from 'src/product_variant/entites/product-variant.entity';
import { CreateCartItemDto } from './dtos/create-cart_item.dto';
import {
  ErrorCodeProductVariant,
  ErrorMessageProductvariant,
} from 'src/product_variant/constants/error-code-product-variant.constant';
import { User } from 'src/user/entities/user.entity';
import { UpdateCartItemDto } from './dtos/update-cart_item.dto';
import {
  ErrorCodeCartItem,
  ErrorMessageCartItem,
} from './constants/error-code-cart_item.constant';
import { CartItemFilterType } from './interfaces/cart-item.filter-type.interface';
import { SORT_BY_CART_ITEM } from './constants/cart-item.sort-by.constant';

@Injectable()
export class CartItemService {
  constructor(
    @InjectRepository(CartItem)
    private readonly cartItemRepository: Repository<CartItem>,
    @InjectRepository(ProductVariant)
    private readonly productVariantRepository: Repository<ProductVariant>,
  ) {}

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

  async checkQuantity(
    productVariant: ProductVariant,
    quantity: number,
  ): Promise<void> {
    if (productVariant.inventory < quantity) {
      throw new HttpException(
        ErrorMessageProductvariant[704],
        ErrorCodeProductVariant.INVENTORY_NOT_ENOUGH,
      );
    }
  }

  async checkQuantyCartItem(
    cartItem: CartItem,
    quantiy: number,
  ): Promise<void> {
    const productVariant = await this.checkProductVariantId(
      cartItem.product_variant_id,
    );
    await this.checkQuantity(productVariant, quantiy);
  }

  private async checkCartItemId(id: number): Promise<CartItem> {
    const cartItem = await this.cartItemRepository.findOne({
      where: { id: id },
    });
    if (!cartItem) {
      throw new HttpException(
        ErrorMessageCartItem[801],
        ErrorCodeCartItem.CART_ITEM_NOT_FOUND,
      );
    }
    return cartItem;
  }

  private async checkExistCartItem(
    userId: number,
    productVariantId: number,
  ): Promise<CartItem | null> {
    const cartItem = await this.cartItemRepository.findOne({
      where: { user_id: userId, product_variant_id: productVariantId },
    });
    if (cartItem) {
      return cartItem;
    }
    return null;
  }

  async create(user: User, data: CreateCartItemDto): Promise<any> {
    const cartItemExist = await this.checkExistCartItem(
      user.id,
      data.product_variant_id,
    );
    if (cartItemExist) {
      const newQuantity = data.quantity + cartItemExist.quantity;
      return await this.update(cartItemExist.id, {
        quantity: newQuantity,
      });
    } else {
      const productVariant = await this.checkProductVariantId(
        data.product_variant_id,
      );
      await this.checkQuantity(productVariant, data.quantity);

      const cartItem = await this.cartItemRepository.create({
        user_id: user.id,
        order_id: null,
        product_variant_id: productVariant.id,
        quantity: data.quantity,
      });

      await this.cartItemRepository.save(cartItem);

      const cartItemRelation = await this.getCartItemRelation(cartItem.id);

      return await this.getOneCartItemOption(cartItemRelation);
    }
  }

  async update(id: number, data: UpdateCartItemDto): Promise<any> {
    const cartItem = await this.checkCartItemId(id);
    await this.checkQuantyCartItem(cartItem, data.quantity);
    cartItem.quantity = data.quantity;
    await this.cartItemRepository.save(cartItem);
    const cartItemRelation = await this.getCartItemRelation(cartItem.id);

    return await this.getOneCartItemOption(cartItemRelation);
  }

  private async getCartItemRelation(id: number): Promise<CartItem> {
    const query = this.cartItemRepository.createQueryBuilder('cart_item');
    query.leftJoinAndSelect('cart_item.productVariant', 'productVariant');
    query.leftJoinAndSelect('productVariant.product', 'product');
    query.leftJoinAndSelect('productVariant.image', 'image');
    query.andWhere(
      new Brackets((qb) => {
        qb.andWhere('cart_item.id = :id', { id: id });
      }),
    );
    const cartItemRelation = await query.getOne();
    return cartItemRelation;
  }

  async getList(user: User, filter: CartItemFilterType): Promise<any> {
    let itemsPerPage: number = Number(filter.items_per_page) || 10;
    if (itemsPerPage > 50) {
      itemsPerPage = 50;
    }
    const page: number = filter.page || 1;
    const search: string = filter.search || '';
    const skip = page - 1 ? (page - 1) * itemsPerPage : 0;
    let sort_by: string = filter.sort_by || 'created_at';
    const order_by = filter.order_by?.toLowerCase() === 'desc' ? 'ASC' : 'DESC';
    if (!SORT_BY_CART_ITEM.includes(sort_by)) {
      sort_by = 'created_at';
    }
    const user_id: number = user.id;
    const query = this.cartItemRepository.createQueryBuilder('cart_item');
    query.andWhere(
      new Brackets((qb) => {
        qb.where('cart_item.user_id  =:user_id', { user_id });
      }),
    );
    query.orderBy(`cart_item.${sort_by}`, order_by);
    query.skip(skip);
    query.take(itemsPerPage);
    query.leftJoinAndSelect('cart_item.productVariant', 'productVariant');
    query.leftJoinAndSelect('productVariant.product', 'product');
    query.leftJoinAndSelect('productVariant.image', 'image');

    const [data, total] = await query.getManyAndCount();
    const cartItemOptions = await this.getListCartItemOption(data);
    return {
      cartItems: cartItemOptions,
      total: total,
    };
  }

  async remove(id: number): Promise<any> {
    const cartItem = await this.checkCartItemId(id);
    await this.cartItemRepository.remove(cartItem);
    const cartItemOption = await this.getOneCartItemOption(cartItem);
    return {
      message: 'xoá thành công giỏ hàng',
      cartItem: cartItemOption,
    };
  }

  async getOneCartItemOption(cartItem: CartItem): Promise<any> {
    return {
      id: cartItem.id,
      product_variant_id: cartItem.product_variant_id,
      product_name: cartItem.productVariant.product.name,
      product_variant_name: cartItem.productVariant.name,
      image: cartItem.productVariant.image.path,
      price: Number(cartItem.productVariant.price),
      promotion:
        Number(cartItem.productVariant.price) *
        (Number(cartItem.productVariant.discount_rate) / 100),
      quantity: cartItem.quantity,
    };
  }

  private async getListCartItemOption(cart_items: CartItem[]): Promise<any> {
    const cartItemOptions = await Promise.all(
      cart_items.map((cartItem) => this.getOneCartItemOption(cartItem)),
    );
    return cartItemOptions;
  }
}
