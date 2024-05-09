import { Module, ValidationPipe } from '@nestjs/common';

import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './auth/auth.module';
import { UserModule } from './user/user.module';
import typeorm from './config/typeorm';
import { APP_GUARD, APP_PIPE } from '@nestjs/core';
import { AuthGuard } from './auth/auth.guard';
import { RoleGuard } from './auth/role.guard';
import { User } from './user/entities/user.entity';
import { Token } from './token/entities/token.entity';
import { JwtService } from '@nestjs/jwt';
import { ProductModule } from './product/product.module';
import { CategoryModule } from './category/category.module';
import { ImageModule } from './image/image.module';
import { ProductVariantModule } from './product_variant/product_variant.module';
import { CartItemModule } from './cart_item/cart_item.module';
import { AddressModule } from './address/address.module';
import { WishListModule } from './wish_list/wish_list.module';
import { OrderModule } from './order/order.module';
import { FeeShippingModule } from './fee-shipping/fee-shipping.module';
import { BullModule } from '@nestjs/bull';
import { OrderHistoryModule } from './order-history/order-history.module';
import { VnpayModule } from './vnpay/vnpay.module';
import { RevenueModule } from './revenue/revenue.module';
import { MailerModule } from '@nestjs-modules/mailer';

import { MailModule } from './mail/mail.module';
import { HandlebarsAdapter } from '@nestjs-modules/mailer/dist/adapters/handlebars.adapter';
import { FeedBackModule } from './feed_back/feed_back.module';

import { EventEmitterModule } from '@nestjs/event-emitter';
import { ScheduleModule } from '@nestjs/schedule';

@Module({
  imports: [
    EventEmitterModule.forRoot(),
    ScheduleModule.forRoot(),
    BullModule.forRoot('alternate-config', {
      redis: {
        host: '172.17.0.2',
        port: 6379,
      },
    }),

    ConfigModule.forRoot({
      isGlobal: true,
      load: [typeorm],
      envFilePath: '.env',
    }),
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: async (configService: ConfigService) =>
        configService.get('typeorm'),
    }),

    TypeOrmModule.forFeature([User, Token]),
    AuthModule,
    UserModule,
    ProductModule,
    CategoryModule,
    ImageModule,
    ProductVariantModule,
    CartItemModule,
    AddressModule,
    WishListModule,
    OrderModule,
    FeeShippingModule,
    OrderHistoryModule,
    VnpayModule,
    RevenueModule,
    MailModule,
    MailerModule.forRootAsync({
      inject: [ConfigService],
      useFactory: async (configService: ConfigService) => ({
        transport: {
          host: configService.get('MAIL_HOST'),
          secure: false,
          auth: {
            user: configService.get('MAIL_USER'),
            pass: configService.get('MAIL_PASSWORD'),
          },
        },
        defaults: {
          from: `"No Reply"<${configService.get('MAIL_FROM')}>`,
        },
        template: {
          dir: 'src/templates/email',
          adapter: new HandlebarsAdapter(),
          options: {
            strict: true,
          },
        },
      }),
    }),
    FeedBackModule,
  ],
  controllers: [],
  providers: [
    ConfigService,
    JwtService,
    {
      provide: APP_GUARD,
      useClass: AuthGuard,
    },
    {
      provide: APP_GUARD,
      useClass: RoleGuard,
    },
  ],
})
export class AppModule {}
