import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Put,
  Query,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { ProductService } from './product.service';
import BaseController from 'src/ultils/base/response.base';
import { Roles } from 'src/auth/decorators/role.decorator';
import { CreateProductDto } from './dtos/create-product.dto';
import { FileInterceptor } from '@nestjs/platform-express';
import CommonError from 'src/ultils/base/error-code.base';
import { UpdateProductDto } from './dtos/update-product.dto';
import { ProductFilterType } from './interface/product.filter-type.interface';
import { Public } from 'src/auth/decorators/public.decorator';
import { ValidateDto } from 'src/ultils/decorators/pipe-validate.decorator';

@Controller('product')
export class ProductController extends BaseController {
  constructor(private readonly productService: ProductService) {
    super();
  }

  @Public()
  @Get()
  async getAll(@Query() filter: ProductFilterType): Promise<any> {
    try {
      const result = await this.productService.getList(filter);
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
  @Get('count')
  async getCount(@Query() filter: ProductFilterType): Promise<any> {
    try {
      const result = await this.productService.countProduct(filter.search);
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
  @Get('top-selling')
  async get5Product(): Promise<any> {
    try {
      const result = await this.productService.getTop5SellingProducts();
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
  @Get(':id')
  async getDetail(@Param('id', ParseIntPipe) id: number): Promise<any> {
    try {
      console.log('run api get detail product ', id);
      const result = await this.productService.getDetail(id);
      if (result instanceof CommonError) {
        throw result;
      }
      return this.data(result);
    } catch (error) {
      if (error instanceof CommonError) return error;
      return this.fail(error);
    }
  }

  @Post()
  @Roles('admin')
  @ValidateDto()
  @UseInterceptors(FileInterceptor('productImage'))
  async create(
    @Body() body: CreateProductDto,
    @UploadedFile()
    productImage: Express.Multer.File,
  ): Promise<any> {
    try {
      const result = await this.productService.create(body, productImage);
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
  @ValidateDto()
  @UseInterceptors(FileInterceptor('productImage'))
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() body: UpdateProductDto,
    @UploadedFile()
    productImage?: Express.Multer.File,
  ): Promise<any> {
    try {
      console.log('run api update product');
      console.log(body);
      const result = await this.productService.update(id, body, productImage);
      if (result instanceof CommonError) {
        throw result;
      }
      console.log(result);
      return this.data(result);
    } catch (error) {
      if (error instanceof CommonError) return error;
      return this.fail(error);
    }
  }

  @Delete(':id')
  @Roles('admin')
  async remove(@Param('id', ParseIntPipe) id: number): Promise<any> {
    try {
      const result = await this.productService.remove(id);
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
