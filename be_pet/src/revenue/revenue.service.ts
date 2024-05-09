import { HttpException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Order } from 'src/order/entities/order.entity';
import { Repository } from 'typeorm';
import {
  ErrorCodeRevenue,
  ErrorMessageRevenue,
} from './constants/error-code-revenue.constant';

@Injectable()
export class RevenueService {
  constructor(
    @InjectRepository(Order)
    private readonly orderRepository: Repository<Order>,
  ) {}

  async calculateRevenue(startDate: Date, endDate: Date): Promise<number> {
    try {
      const query = this.orderRepository.createQueryBuilder('order');
      query
        .select('SUM(order.total_money)', 'totalRevenue')
        .andWhere('t_order.created_at BETWEEN :startDate AND :endOfDay', {
          startDate,
          endOfDay: new Date(endDate.getTime() + 24 * 60 * 60 * 1000 - 1),
        });
      const result = await query.getRawOne();

      return result?.totalRevenue || 0;
    } catch (error) {
      throw new HttpException(
        ErrorMessageRevenue[1201],
        ErrorCodeRevenue.ERROR_CALCULATE_REVENUE,
      );
    }
  }
}
