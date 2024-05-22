import {
  Controller,
  Get,
  HttpException,
  HttpStatus,
  Param,
} from '@nestjs/common';
import { RevenueService } from './revenue.service';
import BaseController from 'src/ultils/base/response.base';
import { Roles } from 'src/auth/decorators/role.decorator';
import CommonError from 'src/ultils/base/error-code.base';

@Controller('revenue')
export class RevenueController extends BaseController {
  constructor(private readonly revenueService: RevenueService) {
    super();
  }

  @Roles('admin')
  @Get('/:startDate/:endDate')
  async revenue(
    @Param('startDate') startDate: string,
    @Param('endDate') endDate: string,
  ): Promise<any> {
    try {
      const startDateObj = new Date(startDate);
      const endDateObj = new Date(endDate);

      if (isNaN(startDateObj.getTime()) || isNaN(endDateObj.getTime())) {
        throw new HttpException('Invalid date format', HttpStatus.BAD_REQUEST);
      }

      const result = await this.revenueService.calculateRevenue(
        startDateObj,
        endDateObj,
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

  @Roles('admin')
  @Get('six-month')
  async revenue6Month(): Promise<any> {
    console.log('run api get 6 month revenue');
    try {
      const result = await this.revenueService.calculateRevenueLastSixMonths();

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
}
