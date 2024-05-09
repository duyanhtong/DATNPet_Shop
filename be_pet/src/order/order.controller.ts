import {
  Body,
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Post,
  Put,
  Query,
  Request,
} from '@nestjs/common';
import { OrderService } from './order.service';
import { FeeShippingDto } from './dtos/fee_shipping.dto';
import BaseController from 'src/ultils/base/response.base';
import { Roles } from 'src/auth/decorators/role.decorator';
import CommonError from 'src/ultils/base/error-code.base';
import { CreateOrderDto } from './dtos/create-order.dto';
import { ValidateDto } from 'src/ultils/decorators/pipe-validate.decorator';
import { JwtAuthReq } from 'src/auth/decorators/strategy.decorator';
import { Transaction } from 'typeorm';
import { OrderFilterType } from './interface/order.filter-type.interface';
import { updateStatusOrderDto } from './dtos/update_status_order.dto';

@Controller('order')
export class OrderController extends BaseController {
  constructor(private readonly orderService: OrderService) {
    super();
  }

  @ValidateDto()
  @Post()
  @JwtAuthReq()
  @Roles('user', 'admin')
  async create(
    @Body() data: CreateOrderDto,
    @Request() req: any,
  ): Promise<any> {
    try {
      console.log('run api create order');
      console.log(data);
      const result = await this.orderService.create(req.user, data);
      if (result instanceof CommonError) {
        throw result;
      }
      return this.data(result);
    } catch (error) {
      if (error instanceof CommonError) return error;
      return this.fail(error);
    }
  }

  @ValidateDto()
  @Roles('user', 'admin')
  @Post('fee-shipping')
  async getFeeShipping(@Body() data: FeeShippingDto): Promise<any> {
    try {
      console.log('run api calculate feeShipping');
      const result = await this.orderService.calculateFeeShipping(data);
      if (result instanceof CommonError) {
        throw result;
      }
      return this.data(result);
    } catch (error) {
      if (error instanceof CommonError) return error;
      return this.fail(error);
    }
  }

  @JwtAuthReq()
  @Get()
  @Roles('admin', 'user')
  async getList(
    @Query() filter: OrderFilterType,
    @Request() req: any,
  ): Promise<any> {
    try {
      console.log('run api get list order');
      console.log(filter);
      const result = await this.orderService.getList(req.user, filter);
      if (result instanceof CommonError) {
        throw result;
      }
      return this.data(result);
    } catch (error) {
      if (error instanceof CommonError) return error;
      return this.fail(error);
    }
    //return await this.orderService.getList(req.user, filter);
  }

  @Get('count')
  @Roles('admin')
  async count(@Query() data: any): Promise<any> {
    try {
      console.log('run api count order: ', data.status);

      const result = await this.orderService.countOrderByStatus(data.status);
      if (result instanceof CommonError) {
        throw result;
      }
      return this.data(result);
    } catch (error) {
      if (error instanceof CommonError) return error;
      return this.fail(error);
    }
  }

  @Get(':id')
  @Roles('admin', 'user')
  async getDetail(@Param('id', ParseIntPipe) id: number): Promise<any> {
    try {
      console.log('run api get detail order: ', id);

      const result = await this.orderService.getDetail(id);
      if (result instanceof CommonError) {
        throw result;
      }
      return this.data(result);
    } catch (error) {
      if (error instanceof CommonError) return error;
      return this.fail(error);
    }
  }

  @Put('status/:id')
  @Roles('admin', 'user')
  async status(
    @Param('id', ParseIntPipe) id: number,
    @Body() data: updateStatusOrderDto,
  ): Promise<any> {
    try {
      console.log('run api get update status order: ', id, data.status);

      const result = await this.orderService.updateStatus(id, data);
      if (result instanceof CommonError) {
        throw result;
      }
      console.log(result);
      return this.data(result);
    } catch (error) {
      console.log(error);
      if (error instanceof CommonError) return error;
      return this.fail(error);
    }
  }
}
