import { Body, Controller, Get, Post, Query, Request } from '@nestjs/common';
import { WishListService } from './wish_list.service';
import BaseController from 'src/ultils/base/response.base';
import { ValidateDto } from 'src/ultils/decorators/pipe-validate.decorator';
import { JwtAuthReq } from 'src/auth/decorators/strategy.decorator';
import { Roles } from 'src/auth/decorators/role.decorator';
import { CreateWishListDto } from './dtos/create-wish_list.dto';
import CommonError from 'src/ultils/base/error-code.base';
import { WishListFilterType } from './interfaces/wish-list.filter-type.interface';

@Controller('wish-list')
export class WishListController extends BaseController {
  constructor(private readonly wishListService: WishListService) {
    super();
  }

  @ValidateDto()
  @Post()
  @JwtAuthReq()
  @Roles('user', 'admin')
  async create(
    @Body() data: CreateWishListDto,
    @Request() req: any,
  ): Promise<any> {
    try {
      const result = await this.wishListService.create(req.user, data);
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
  @Post('check')
  @JwtAuthReq()
  @Roles('user', 'admin')
  async check(
    @Body() data: CreateWishListDto,
    @Request() req: any,
  ): Promise<any> {
    try {
      const result = await this.wishListService.checkExistWishList(
        req.user.id,
        data.product_id,
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

  @JwtAuthReq()
  @Get()
  @Roles('admin', 'user')
  async getList(
    @Query() filter: WishListFilterType,
    @Request() req: any,
  ): Promise<any> {
    try {
      console.log('run api get list wishList');
      const result = await this.wishListService.getList(req.user, filter);
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
