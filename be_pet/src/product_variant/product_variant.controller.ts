import {
  Body,
  Controller,
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

@Controller('product-variant')
export class ProductVariantController extends BaseController {
  constructor(private readonly productVariantService: ProductVariantService) {
    super();
  }

  @Post()
  @Roles('admin')
  @UseInterceptors(FileInterceptor('productImage'))
  async create(
    @Body() body: CreateProductVariantDto,
    @UploadedFile()
    productImage: Express.Multer.File,
  ): Promise<any> {
    try {
      const result = await this.productVariantService.create(
        body,
        productImage,
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
  @UseInterceptors(FileInterceptor('productImage'))
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() body: UpdateProductVariantDto,
    @UploadedFile()
    productImage: Express.Multer.File,
  ): Promise<any> {
    try {
      const result = await this.productVariantService.update(
        id,
        body,
        productImage,
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
}
