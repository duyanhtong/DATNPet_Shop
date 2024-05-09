import {
  Body,
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Put,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { ProductVariantService } from './product_variant.service';
import BaseController from 'src/ultils/base/response.base';
import { Roles } from 'src/auth/decorators/role.decorator';
import { FileInterceptor } from '@nestjs/platform-express';
import { CreateProductVariantDto } from './dtos/create-product-variant.dto';
import CommonError from 'src/ultils/base/error-code.base';
import { UpdateProductVariantDto } from './dtos/update-product-variant.dto';
import { Public } from 'src/auth/decorators/public.decorator';

@Controller('product-variant')
export class ProductVariantController extends BaseController {
  constructor(private readonly productVariantService: ProductVariantService) {
    super();
  }

  @Post()
  @Roles('admin')
  @UseInterceptors(FileInterceptor('productVariantImage'))
  async create(
    @Body() body: CreateProductVariantDto,
    @UploadedFile()
    productVariantImage: Express.Multer.File,
  ): Promise<any> {
    try {
      console.log('run api create product variant');
      const result = await this.productVariantService.create(
        body,
        productVariantImage,
      );
      if (result instanceof CommonError) {
        throw result;
      }
      return this.data(result);
    } catch (error) {
      if (error instanceof CommonError) return error;
      return this.fail(error);
    }
  }

  @Put(':id')
  @Roles('admin')
  @UseInterceptors(FileInterceptor('productVariantImage'))
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() body: UpdateProductVariantDto,
    @UploadedFile()
    productVariantImage: Express.Multer.File,
  ): Promise<any> {
    try {
      const result = await this.productVariantService.update(
        id,
        body,
        productVariantImage,
      );
      if (result instanceof CommonError) {
        throw result;
      }
      return this.data(result);
    } catch (error) {
      if (error instanceof CommonError) return error;
      return this.fail(error);
    }
  }

  @Public()
  @Get('product/:id')
  async getDetail(@Param('id', ParseIntPipe) id: number): Promise<any> {
    try {
      const result =
        await this.productVariantService.getProductByProductvariantId(id);
      if (result instanceof CommonError) {
        throw result;
      }
      return this.data(result);
    } catch (error) {
      if (error instanceof CommonError) return error;
      return this.fail(error);
    }
  }
}
