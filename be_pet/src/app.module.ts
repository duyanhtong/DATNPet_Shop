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

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [typeorm],
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
  ],
  controllers: [],
  providers: [
    ConfigService,
    JwtService,
    // {
    //   provide: APP_PIPE,
    //   useClass: ValidationPipe,
    // },
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
