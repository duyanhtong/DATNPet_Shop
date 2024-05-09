import { Module } from '@nestjs/common';
import { WishListService } from './wish_list.service';
import { WishListController } from './wish_list.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { WishList } from './entities/wish-list.entity';
import { Product } from 'src/product/entities/product.entity';
import { ProductService } from 'src/product/product.service';
import { Image } from 'src/image/entities/image.entity';
import { ImageService } from 'src/image/image.service';
import { Category } from 'src/category/entities/category.entity';

@Module({
  imports: [TypeOrmModule.forFeature([WishList, Product, Image, Category])],
  controllers: [WishListController],
  providers: [WishListService, ProductService, ImageService],
})
export class WishListModule {}
