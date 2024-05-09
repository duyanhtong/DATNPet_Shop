import { Module } from '@nestjs/common';
import { OrderService } from './order.service';
import { OrderController } from './order.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CartItem } from 'src/cart_item/entities/cart-item.entity';
import { Order } from './entities/order.entity';
import { Product } from 'src/product/entities/product.entity';
import { ProductVariant } from 'src/product_variant/entites/product-variant.entity';
import { FeeShippingService } from 'src/fee-shipping/fee-shipping.service';
import { Address } from 'src/address/entities/address.entity';
import { MailService } from 'src/mail/mail.service';
import { BullModule } from '@nestjs/bull';
import { EmailConsumer } from './consumers/email.consumer';
import { FeedBackService } from 'src/feed_back/feed_back.service';
import { Feedback } from 'src/feed_back/entities/feed_back.entity';
import { ImageService } from 'src/image/image.service';
import { Image } from 'src/image/entities/image.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Order,
      CartItem,
      Product,
      ProductVariant,
      Address,
      Feedback,
      Image,
    ]),

    BullModule.registerQueue({
      configKey: 'alternate-config',
      name: 'SEND_MAIL_QUEUE',
    }),
  ],
  controllers: [OrderController],
  providers: [
    OrderService,
    FeeShippingService,
    MailService,
    EmailConsumer,
    FeedBackService,
    ImageService,
  ],
})
export class OrderModule {}
