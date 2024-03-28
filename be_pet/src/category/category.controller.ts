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
} from '@nestjs/common';
import { CategoryService } from './category.service';
import BaseController from 'src/ultils/base/response.base';
import { Public } from 'src/auth/decorators/public.decorator';
import { CategoryFilterType } from './interface/category.filter-type.interface';
import CommonError from 'src/ultils/base/error-code.base';
import { Roles } from 'src/auth/decorators/role.decorator';
import { CreateCategoryDto } from './dtos/create-category.dto';
import { UpdateCategoryDto } from './dtos/update-category.dto';
import { JwtAuthReq } from 'src/auth/decorators/strategy.decorator';

@Controller('category')
export class CategoryController extends BaseController {
  constructor(private readonly categoryService: CategoryService) {
    super();
  }

  @Public()
  @Get()
  async getList(@Query() filter: CategoryFilterType): Promise<any> {
    try {
      const result = await this.categoryService.getList(filter);
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
  async create(@Body() body: CreateCategoryDto): Promise<any> {
    try {
      const result = await this.categoryService.create(body);
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
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() body: UpdateCategoryDto,
  ): Promise<any> {
    try {
      const result = await this.categoryService.update(id, body);
      if (result instanceof CommonError) {
        throw result;
      }
      return this.data(result);
    } catch (error) {
      if (error instanceof CommonError) return error;
      return this.fail(error);
    }
  }

  @Roles('admin')
  @Get(':id')
  async getDetail(@Param('id', ParseIntPipe) id: number): Promise<any> {
    try {
      const result = await this.categoryService.getDetail(id);
      if (result instanceof CommonError) {
        throw result;
      }
      return this.data(result);
    } catch (error) {
      if (error instanceof CommonError) return error;
      return this.fail(error);
    }
  }

  @Roles('admin')
  @Delete(':id')
  async delete(@Param('id', ParseIntPipe) id: number): Promise<any> {
    try {
      const result = await this.categoryService.remove(id);
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
