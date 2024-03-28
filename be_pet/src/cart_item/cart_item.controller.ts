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
  Request,
} from '@nestjs/common';
import { CartItemService } from './cart_item.service';
import BaseController from 'src/ultils/base/response.base';
import { Roles } from 'src/auth/decorators/role.decorator';
import { CreateCartItemDto } from './dtos/create-cart_item.dto';
import { ValidateDto } from 'src/ultils/decorators/pipe-validate.decorator';
import { JwtAuthReq } from 'src/auth/decorators/strategy.decorator';
import CommonError from 'src/ultils/base/error-code.base';
import { CartItemFilterType } from './interfaces/cart-item.filter-type.interface';
import { UpdateCartItemDto } from './dtos/update-cart_item.dto';

@Controller('cart-item')
export class CartItemController extends BaseController {
  constructor(private readonly cartItemService: CartItemService) {
    super();
  }

  @ValidateDto()
  @Post()
  @JwtAuthReq()
  @Roles('user', 'admin')
  async create(
    @Body() data: CreateCartItemDto,
    @Request() req: any,
  ): Promise<any> {
    try {
      const result = await this.cartItemService.create(req.user, data);
      if (result instanceof CommonError) {
        throw result;
      }
      return this.data(result);
    } catch (error) {
      if (error instanceof CommonError) return error;
      return this.fail(error);
    }
    // return await this.cartItemService.create(req.user, data);
  }

  @JwtAuthReq()
  @Get()
  @Roles('admin', 'user')
  async getList(
    @Query() filter: CartItemFilterType,
    @Request() req: any,
  ): Promise<any> {
    try {
      console.log('run api get list cart item');
      const result = await this.cartItemService.getList(req.user, filter);
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
  @Roles('admin', 'user')
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() body: UpdateCartItemDto,
  ): Promise<any> {
    try {
      const result = await this.cartItemService.update(id, body);
      if (result instanceof CommonError) {
        throw result;
      }
      return this.data(result);
    } catch (error) {
      if (error instanceof CommonError) return error;
      return this.fail(error);
    }
  }

  @Roles('admin', 'user')
  @Delete(':id')
  async delete(@Param('id', ParseIntPipe) id: number): Promise<any> {
    try {
      const result = await this.cartItemService.remove(id);
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
