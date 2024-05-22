import { Module } from '@nestjs/common';
import { ProductService } from './product.service';
import { ProductController } from './product.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Product } from './entities/product.entity';
import { Image } from 'src/image/entities/image.entity';
import { ImageService } from 'src/image/image.service';
import { Category } from 'src/category/entities/category.entity';
import { ProductVariant } from 'src/product_variant/entites/product-variant.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([Product, Image, Category, ProductVariant]),
  ],
  controllers: [ProductController],
  providers: [ProductService, ImageService],
})
export class ProductModule {}
