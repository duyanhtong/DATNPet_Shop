import { Module } from '@nestjs/common';
import { FeedBackService } from './feed_back.service';
import { FeedBackController } from './feed_back.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Feedback } from './entities/feed_back.entity';
import { Product } from 'src/product/entities/product.entity';
import { ImageService } from 'src/image/image.service';
import { Image } from 'src/image/entities/image.entity';
import { ProductVariant } from 'src/product_variant/entites/product-variant.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([Feedback, Product, Image, ProductVariant]),
  ],
  controllers: [FeedBackController],
  providers: [FeedBackService, ImageService],
})
export class FeedBackModule {}
