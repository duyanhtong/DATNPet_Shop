import { Module } from '@nestjs/common';
import { ProductVariantService } from './product_variant.service';
import { ProductVariantController } from './product_variant.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProductVariant } from './entites/product-variant.entity';
import { Product } from 'src/product/entities/product.entity';
import { ImageService } from 'src/image/image.service';
import { Image } from 'src/image/entities/image.entity';
import { ProductService } from 'src/product/product.service';
import { Category } from 'src/category/entities/category.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([ProductVariant, Product, Image, Category]),
  ],
  controllers: [ProductVariantController],
  providers: [ProductVariantService, ImageService, ProductService],
})
export class ProductVariantModule {}
