import { HttpException, Inject, Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Order } from './entities/order.entity';
import {
  Brackets,
  DataSource,
  In,
  Not,
  QueryRunner,
  Repository,
} from 'typeorm';
import { Product } from 'src/product/entities/product.entity';
import { CartItem } from 'src/cart_item/entities/cart-item.entity';
import {
  ErrorCodeCartItem,
  ErrorMessageCartItem,
} from 'src/cart_item/constants/error-code-cart_item.constant';
import { Address } from 'src/address/entities/address.entity';
import {
  ErrorCodeAddress,
  ErrorMessageAddress,
} from 'src/address/constants/error-code-cart_item.constant';
import { User } from 'src/user/entities/user.entity';
import { CreateOrderDto } from './dtos/create-order.dto';
import { ProductVariant } from 'src/product_variant/entites/product-variant.entity';
import {
  ErrorCodeProductVariant,
  ErrorMessageProductvariant,
} from 'src/product_variant/constants/error-code-product-variant.constant';
import { OrderStatusEnum } from './constants/order.status.constant';
import { FeeShippingService } from 'src/fee-shipping/fee-shipping.service';
import { ConfigService } from '@nestjs/config';
import { FeeShippingDto } from './dtos/fee_shipping.dto';
import {
  ErrorCodeProduct,
  ErrorMessageProduct,
} from 'src/product/constants/error-code-product.constant';
import {
  ErrorCodeOrder,
  ErrorMessageOrder,
} from './constants/error-code-order.constant';
import { OrderHistory } from 'src/order-history/entities/order-history.entity';
import { OrderFilterType } from './interface/order.filter-type.interface';
import { SORT_BY_ORDER } from './constants/order.sort-by.constant';
import { updateStatusOrderDto } from './dtos/update_status_order.dto';
import { InjectQueue } from '@nestjs/bull';
import { Queue } from 'bull';
import { MailService } from 'src/mail/mail.service';
import { ItemsGHN } from './interface/items-GHN.interface';
import { FeedBackService } from 'src/feed_back/feed_back.service';

@Injectable()
export class OrderService {
  private readonly PROVINCE_STORE: string;
  private readonly DISTRICT_STORE: string;
  private readonly WARD_STORE: string;

  constructor(
    @InjectRepository(Order)
    private readonly orderRepository: Repository<Order>,
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
    @InjectRepository(CartItem)
    private readonly cartItemRepository: Repository<CartItem>,
    @InjectRepository(Address)
    private readonly addressRepository: Repository<Address>,
    @InjectRepository(ProductVariant)
    private readonly productVariantRepository: Repository<ProductVariant>,
    private readonly feeShippingService: FeeShippingService,
    private readonly configService: ConfigService,
    @InjectQueue('SEND_MAIL_QUEUE') private readonly queue: Queue,
    private readonly mailService: MailService,
    @Inject(DataSource)
    private readonly dataSource: DataSource,
    private readonly feedbackService: FeedBackService,
  ) {
    this.PROVINCE_STORE = this.configService.get('PROVINCE_SHOP');
    this.DISTRICT_STORE = this.configService.get('DISTRICT_SHOP');
    this.WARD_STORE = this.configService.get('WARD_SHOP');
  }

  private async checkOrderId(orderId: number): Promise<Order> {
    const order = await this.orderRepository.findOne({
      where: { id: orderId },
    });

    if (!order) {
      throw new HttpException(
        ErrorMessageOrder[1102],
        ErrorCodeOrder.ORDER_NOT_FOUND,
      );
    }

    return order;
  }

  private async checkCartId(cartId: number): Promise<CartItem> {
    const cartItem = await this.cartItemRepository.findOne({
      where: { id: cartId },
    });
    if (!cartItem) {
      throw new HttpException(
        ErrorMessageCartItem[801],
        ErrorCodeCartItem.CART_ITEM_NOT_FOUND,
      );
    }

    if (cartItem.order_id) {
      throw new HttpException(
        ErrorMessageCartItem[802],
        ErrorCodeCartItem.CART_HAS_ORDER,
      );
    }

    return cartItem;
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

  private async checkExistCart(cartIds: number[]): Promise<void> {
    await Promise.all(
      cartIds.map(async (cartId) => {
        await this.checkCartId(cartId);
      }),
    );
  }

  private async checkAddressId(addressId: number): Promise<Address> {
    const address = await this.addressRepository.findOne({
      where: { id: addressId },
    });
    if (!address) {
      throw new HttpException(
        ErrorMessageAddress[901],
        ErrorCodeAddress.ADDRESS_NOT_FOUND,
      );
    }
    return address;
  }

  private async getCartItemAndProductVariant(cartId: number): Promise<{
    name: string;
    quantity: number;
    weight: number;
    price: number;
  }> {
    const cartItem = await this.checkCartId(cartId);
    const productVariant = await this.checkProductVariantId(
      cartItem.product_variant_id,
    );
    if (cartItem.quantity > productVariant.inventory) {
      cartItem.quantity = productVariant.inventory;
      await this.cartItemRepository.save(cartItem);
      throw new HttpException(
        ErrorMessageOrder[1101],
        ErrorCodeOrder.INVENTORY_PRODUCT_NOT_ENOUGH,
      );
    }
    return {
      name: productVariant.name,
      quantity: cartItem.quantity,
      weight: productVariant.weight,
      price:
        productVariant.price -
        (productVariant.discount_rate * productVariant.price) / 100,
    };
  }

  private async calculateTotalMoney(cartIds: number[]): Promise<number> {
    const totals = await Promise.all(
      cartIds.map(async (cartId) => {
        const { price } = await this.getCartItemAndProductVariant(cartId);
        return price;
      }),
    );
    return totals.reduce((acc, current) => acc + current, 0);
  }

  private async tranformCartItems(cartIds: number[]): Promise<ItemsGHN[]> {
    const transformedItems = await Promise.all(
      cartIds.map(async (cartId) => {
        const { name, quantity, weight } =
          await this.getCartItemAndProductVariant(cartId);
        return { name, quantity, weight };
      }),
    );
    return transformedItems;
  }

  private async calculateTotalWeight(cartIds: number[]): Promise<number> {
    const totalWeights = await Promise.all(
      cartIds.map(async (cartId) => {
        const { weight, quantity } =
          await this.getCartItemAndProductVariant(cartId);
        return weight * quantity;
      }),
    );
    return totalWeights.reduce((acc, current) => acc + current, 0);
  }

  async calculateFeeShipping(data: FeeShippingDto): Promise<any> {
    const address = await this.checkAddressId(data.addressId);
    const totalWeight = await this.calculateTotalWeight(data.cartIds);
    const items = await this.tranformCartItems(data.cartIds);
    const feeShipping = await this.feeShippingService.calculateFeeShipping({
      from_province_name: this.PROVINCE_STORE,
      from_district_name: this.DISTRICT_STORE,
      from_ward_name: this.WARD_STORE,
      to_province_name: address.province,
      to_ward_name: address.ward,
      to_district_name: address.district,
      weight: totalWeight,
      items: items,
    });

    return feeShipping;
  }

  private async RollBackUpdateProduct(order: Order): Promise<void> {
    let queryRunner: QueryRunner;
    try {
      queryRunner = this.dataSource.createQueryRunner();
      await queryRunner.connect();
      await queryRunner.startTransaction();
      for (const cartItem of order.orderHistories) {
        const productVariant = await this.checkProductVariantId(
          cartItem.product_variant_id,
        );
        const product = await this.checkProductId(productVariant.product_id);
        productVariant.inventory += cartItem.quantity;
        await queryRunner.manager.save(productVariant);
        product.sold -= cartItem.quantity;
        await queryRunner.manager.save(product);
      }
      await queryRunner.commitTransaction();
    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  private async updateCartItem(
    cartIds: number[],
    orderId: number,
  ): Promise<void> {
    let queryRunner: QueryRunner;

    try {
      queryRunner = this.dataSource.createQueryRunner();
      await queryRunner.connect();
      await queryRunner.startTransaction();
      for (const cartId of cartIds) {
        const cartItem = await this.checkCartId(cartId);
        const productVariant = await this.checkProductVariantId(
          cartItem.product_variant_id,
        );
        const product = await this.checkProductId(productVariant.product_id);
        cartItem.order_id = orderId;
        await queryRunner.manager.save(cartItem);
        productVariant.inventory -= cartItem.quantity;
        await queryRunner.manager.save(productVariant);
        product.sold += cartItem.quantity;
        await queryRunner.manager.save(product);

        // Tạo bản ghi mới trong order-history
        const orderHistory = queryRunner.manager.create(OrderHistory, {
          order_id: orderId,
          product_variant_id: productVariant.id,
          product_name: product.name,
          product_variant_name: productVariant.name,
          image: productVariant.image.path,
          quantity: cartItem.quantity,
          weight: productVariant.weight,
          price_at_purchase: productVariant.price,
          promotion_at_purchase: productVariant.discount_rate,
        });
        await queryRunner.manager.save(orderHistory);
      }
      await queryRunner.commitTransaction();
    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  async create(user: User, data: CreateOrderDto): Promise<any> {
    let queryRunner: QueryRunner;

    try {
      queryRunner = this.dataSource.createQueryRunner();
      await queryRunner.connect();
      await queryRunner.startTransaction();
      const [address, _, total, feeShipping] = await Promise.all([
        this.checkAddressId(data.address_id),
        this.checkExistCart(data.carts),
        this.calculateTotalMoney(data.carts),
        this.calculateFeeShipping({
          addressId: data.address_id,
          cartIds: data.carts,
        }),
      ]);

      const order = this.orderRepository.create({
        user_id: user.id,
        note: data.note,
        status: OrderStatusEnum.pending_confirmation,
        payment_method: data.payment_method,
        total_money: total,
        fee_shipping: feeShipping,
        province: address.province,
        district: address.district,
        ward: address.ward,
        detail_address: address.detail_address || ' ',
        phone_number: address.phone_number,
        fullname: address.fullname,
        expected_shipping_date: new Date(),
        actual_shipping_date: new Date(),
      });

      await queryRunner.manager.save(order);
      await this.updateCartItem(data.carts, order.id);

      await queryRunner.commitTransaction();
      const orderRelaton = await this.getRelationOrder(order);
      const result = await this.getOneOrderOption(orderRelaton);

      // await this.queue.add('confirm_order', 'dklsmnfkldsmf', {
      //   removeOnComplete: true,
      // });
      // console.log('đã thêm vào queue');

      try {
        await this.mailService.mailConfirmOrder(result);
      } catch (error) {
        console.error('Error sending confirmation email:', error);
      }
      return result;
    } catch (error) {
      if (queryRunner) {
        await queryRunner.rollbackTransaction();
      }
      throw error;
    } finally {
      if (queryRunner) {
        await queryRunner.release();
      }
    }
  }

  async getList(user: User, filter: OrderFilterType): Promise<any> {
    let itemsPerPage: number = Number(filter.items_per_page) || 10;
    if (itemsPerPage > 50) {
      itemsPerPage = 50;
    }
    const page: number = filter.page || 1;
    const search: string = filter.search || '';
    const status: string = filter.status || '';
    const skip = page - 1 ? (page - 1) * itemsPerPage : 0;
    let sort_by: string = filter.sort_by || 'created_at';
    const order_by = filter.order_by?.toLowerCase() === 'asc' ? 'ASC' : 'DESC';
    if (!SORT_BY_ORDER.includes(sort_by)) {
      sort_by = 'created_at';
    }
    const query = this.orderRepository.createQueryBuilder('order');

    query.andWhere(
      new Brackets((qb) => {
        if (user.role == 'user') {
          qb.andWhere('order.user_id = :user_id', { user_id: user.id });
        }
        if (status === OrderStatusEnum.delivered) {
          qb.andWhere(
            '(order.status LIKE :completed OR order.status LIKE :canceled)',
            {
              completed: OrderStatusEnum.delivered,
              canceled: OrderStatusEnum.cancel,
            },
          );
        } else if (status === OrderStatusEnum.waiting_for_delivery) {
          qb.andWhere(
            'order.status NOT LIKE :delivered AND order.status NOT LIKE :canceled AND order.status NOT LIKE :pendingConfirmation AND order.status NOT LIKE :ReadyToPick',
            {
              delivered: OrderStatusEnum.delivered,
              canceled: OrderStatusEnum.cancel,
              pendingConfirmation: OrderStatusEnum.pending_confirmation,
              ReadyToPick: OrderStatusEnum.ready_to_pick,
            },
          );
        } else if (status) {
          qb.andWhere('order.status LIKE :status', {
            status: `%${status}%`,
          });
        }
        if (search) {
          qb.andWhere('order.note LIKE :search', {
            search: `%${search}%`,
          });
        }
      }),
    );

    query.leftJoinAndSelect('order.orderHistories', 'orderHistories');
    query.leftJoinAndSelect('order.user', 'user');
    query.orderBy(`order.${sort_by}`, order_by);
    query.skip(skip);
    query.take(itemsPerPage);
    const [data, total] = await query.getManyAndCount();
    const orderOptions = await this.getListOrderOptions(data);
    return {
      orders: orderOptions,
      total: total,
    };
  }

  async getDetail(id: number): Promise<any> {
    const order = await this.checkOrderId(id);
    const orderRelation = await this.getRelationOrder(order);
    return await this.getOneOrderOption(orderRelation);
  }

  async countOrderByStatus(status?: string): Promise<any> {
    if (!status || status === '') {
      const total = await this.orderRepository.count({
        where: {
          status: Not(In([OrderStatusEnum.delivered])),
        },
      });
      return total;
    } else if (
      status !== OrderStatusEnum.pending_confirmation &&
      status !== OrderStatusEnum.delivered
    ) {
      const total = await this.orderRepository.count({
        where: {
          status: Not(
            In([
              OrderStatusEnum.pending_confirmation,
              OrderStatusEnum.delivered,
            ]),
          ),
        },
      });
      return total;
    } else {
      const total = await this.orderRepository.count({
        where: { status: status },
      });
      return total;
    }
  }

  async cancel(id: number): Promise<any> {
    let queryRunner: QueryRunner;
    try {
      queryRunner = this.dataSource.createQueryRunner();
      await queryRunner.connect();
      await queryRunner.startTransaction();
      const order = await this.checkOrderId(id);
      if (order.status != OrderStatusEnum.pending_confirmation) {
        throw new HttpException(
          ErrorMessageOrder[1103],
          ErrorCodeOrder.ORDER_CANNOT_BE_CANCEL,
        );
      }
      const orderRelation = await this.getRelationOrder(order);
      await this.RollBackUpdateProduct(orderRelation);
      order.status = OrderStatusEnum.cancel;
      await queryRunner.manager.save(order);
      await queryRunner.commitTransaction();
      return {
        message: 'Huỷ Đơn hàng thành công',
      };
    } catch (error) {
      await queryRunner.rollbackTransaction();
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  async updateStatus(id: number, data: updateStatusOrderDto): Promise<any> {
    const order = await this.checkOrderId(id);
    const orderRelation = await this.getRelationOrder(order);
    if (data.status == OrderStatusEnum.cancel) {
      return await this.cancel(id);
    }
    if (data.status == OrderStatusEnum.ready_to_pick) {
      const items: ItemsGHN[] = [];
      let totalWeight = 0;

      orderRelation.orderHistories.forEach((orderHistory) => {
        items.push({
          name: orderHistory.product_name,
          quantity: orderHistory.quantity,
          weight: orderHistory.weight,
        });
        totalWeight += orderHistory.weight;
      });

      const responseGHN = await this.feeShippingService.createOrderGHN({
        from_ward_name: this.WARD_STORE,
        from_district_name: this.DISTRICT_STORE,
        from_province_name: this.PROVINCE_STORE,
        to_ward_name: orderRelation.ward,
        to_district_name: orderRelation.district,
        to_province_name: orderRelation.province,
        totalMoney: orderRelation.total_money,
        weight: totalWeight,
        items: items,
        name_user: orderRelation.fullname,
        phone_user: orderRelation.phone_number,
        address_detail_user: orderRelation.detail_address,
        feeShipping: orderRelation.fee_shipping,
        note: orderRelation.note,
      });
      order.expected_shipping_date = responseGHN.expected_delivery_time;
      order.order_code = responseGHN.order_code;
    }

    if (data.status == OrderStatusEnum.delivered) {
      orderRelation.orderHistories.forEach(async (orderHistory) => {
        const productVariant = await this.checkProductVariantId(
          orderHistory.product_variant_id,
        );
        await this.feedbackService.create({
          product_variant_id: productVariant.id,
          user_id: order.user_id,
          order_id: order.id,
        });
      });
    }

    order.status = data.status;

    await this.orderRepository.save(order);
    return {
      message: `Cập nhật trạng thái :${data.status} thành công.`,
    };
  }

  private async getRelationOrder(order: Order): Promise<Order> {
    return await this.orderRepository.findOne({
      where: { id: order.id },
      relations: ['orderHistories', 'user'],
    });
  }

  private async getOneOrderOption(order: Order): Promise<any> {
    return {
      id: Number(order.id),
      user_id: order.user_id,
      full_name: order.fullname,
      email: order.user.email,
      phone_number: order.phone_number,
      note: order.note,
      status: order.status,
      payment_method: order.payment_method,
      total_money: order.total_money,
      fee_shipping: order.fee_shipping,
      province: order.province,
      district: order.district,
      ward: order.ward,
      detail_address: order.detail_address,
      expected_shipping_date: order.expected_shipping_date,
      actual_shipping_date: order.actual_shipping_date,
      order_created_date: order.created_at,
      cartItems: order.orderHistories.map((orderHistory) => ({
        id: Number(orderHistory.id),
        product_variant_id: Number(orderHistory.product_variant_id),
        product_name: orderHistory.product_name,
        product_variant_name: orderHistory.product_variant_name,
        image: orderHistory.image,
        price: Number(orderHistory.price_at_purchase),
        promotion: Number(
          (
            Number(orderHistory.price_at_purchase) *
            (Number(orderHistory.promotion_at_purchase) / 100)
          ).toFixed(2),
        ),
        quantity: orderHistory.quantity,
      })),
    };
  }

  private async getListOrderOptions(orders: Order[]): Promise<any> {
    return await Promise.all(
      orders.map(async (order) => await this.getOneOrderOption(order)),
    );
  }
}
