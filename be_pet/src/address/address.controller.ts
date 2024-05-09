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
import { AddressService } from './address.service';
import BaseController from 'src/ultils/base/response.base';
import { ValidateDto } from 'src/ultils/decorators/pipe-validate.decorator';
import { JwtAuthReq } from 'src/auth/decorators/strategy.decorator';
import { Roles } from 'src/auth/decorators/role.decorator';
import { CreateAddressDto } from './dtos/create-address.dto';
import CommonError from 'src/ultils/base/error-code.base';
import { AddressFilterType } from './interfaces/address.filter-type.interface';
import { UpdateAddressDto } from './dtos/update-address.dto';
import { Public } from 'src/auth/decorators/public.decorator';

@Controller('address')
export class AddressController extends BaseController {
  constructor(private readonly addressService: AddressService) {
    super();
  }

  @ValidateDto()
  @Post()
  @JwtAuthReq()
  @Roles('user', 'admin')
  async create(
    @Body() data: CreateAddressDto,
    @Request() req: any,
  ): Promise<any> {
    try {
      console.log('run api create address');
      const result = await this.addressService.create(req.user, data);
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
    @Query() filter: AddressFilterType,
    @Request() req: any,
  ): Promise<any> {
    try {
      console.log('run api get list address');
      const result = await this.addressService.getList(req.user, filter);
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
  @Get('default/me')
  @Roles('admin', 'user')
  async getAddressDefault(@Request() req: any): Promise<any> {
    try {
      console.log('run api get address default');
      const result = await this.addressService.getAddressDefaultMe(req.user.id);
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
    @Body() body: UpdateAddressDto,
  ): Promise<any> {
    try {
      const result = await this.addressService.update(id, body);
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
  @Put('update/me')
  @Roles('admin', 'user')
  async updateMe(
    @Request() req: any,
    @Body() body: UpdateAddressDto,
  ): Promise<any> {
    try {
      console.log('run api update address me');
      const result = await this.addressService.updateAddressMe(req.user, body);
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

  @Roles('admin', 'user')
  @Delete(':id')
  async delete(@Param('id', ParseIntPipe) id: number): Promise<any> {
    try {
      const result = await this.addressService.remove(id);
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
  @Get('province')
  async getProvince(): Promise<any> {
    try {
      const result = await this.addressService.getAllProvince();
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
  @Get('district/:provinceCode')
  async getDistrict(@Param('provinceCode') provinceCode: string): Promise<any> {
    try {
      const result =
        await this.addressService.getAllDistrictByCity(provinceCode);
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
  @Get('ward/:districtCode')
  async getWard(@Param('districtCode') districtCode: string): Promise<any> {
    try {
      const result =
        await this.addressService.getAllWardByDistrict(districtCode);
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
  @Get(':id')
  async getDetail(@Param('id', ParseIntPipe) id: number): Promise<any> {
    try {
      const result = await this.addressService.getDetail(id);
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
  async remove(@Param('id', ParseIntPipe) id: number): Promise<any> {
    try {
      const result = await this.addressService.remove(id);
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
