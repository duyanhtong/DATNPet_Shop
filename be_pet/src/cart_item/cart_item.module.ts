import { Module } from '@nestjs/common';
import { CartItemService } from './cart_item.service';
import { CartItemController } from './cart_item.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CartItem } from './entities/cart-item.entity';
import { ProductVariant } from 'src/product_variant/entites/product-variant.entity';
import { Product } from 'src/product/entities/product.entity';

@Module({
  imports: [TypeOrmModule.forFeature([CartItem, ProductVariant, Product])],
  controllers: [CartItemController],
  providers: [CartItemService],
})
export class CartItemModule {}
