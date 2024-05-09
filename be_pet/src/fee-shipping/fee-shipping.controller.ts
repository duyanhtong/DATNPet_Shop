import { Body, Controller, Get, Param, Post, Query } from '@nestjs/common';
import { FeeShippingService } from './fee-shipping.service';
import { Public } from 'src/auth/decorators/public.decorator';

@Controller('fee-shipping')
export class FeeShippingController {
  constructor(private readonly feeShippingService: FeeShippingService) {}

  @Public()
  @Get('province/:name')
  getProvinceId(@Param('name') name: string): Promise<any> {
    return this.feeShippingService.getProvinceId(name);
  }

  @Public()
  @Get('district')
  getDistrictId(
    @Query('provinceName') provinceName: string,
    @Query('districtName') districtName: string,
  ): Promise<any> {
    return this.feeShippingService.getDistrictId(provinceName, districtName);
  }

  @Public()
  @Get('ward')
  getWardCode(
    @Query('provinceName') provinceName: string,
    @Query('districtName') districtName: string,
    @Query('wardName') wardName: string,
  ): Promise<any> {
    return this.feeShippingService.getWardCode(
      provinceName,
      districtName,
      wardName,
    );
  }

  @Public()
  @Post('fee-shipping')
  getFeeShipping(@Body() data): Promise<any> {
    return this.feeShippingService.calculateFeeShipping(data);
  }
}
