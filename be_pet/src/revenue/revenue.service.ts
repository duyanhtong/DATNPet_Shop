import { HttpException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Order } from 'src/order/entities/order.entity';
import { Repository } from 'typeorm';
import {
  ErrorCodeRevenue,
  ErrorMessageRevenue,
} from './constants/error-code-revenue.constant';
import { OrderStatusEnum } from 'src/order/constants/order.status.constant';

@Injectable()
export class RevenueService {
  constructor(
    @InjectRepository(Order)
    private readonly orderRepository: Repository<Order>,
  ) {}

  async calculateRevenue(startDate: Date, endDate: Date): Promise<any> {
    try {
      const query = this.orderRepository.createQueryBuilder('order');
      query
        .select('SUM(order.total_money)', 'totalRevenue')
        .andWhere('order.status ILIKE :status', {
          status: `%${OrderStatusEnum.delivered}%`,
        })
        .andWhere('order.created_at BETWEEN :startDate AND :endOfDay', {
          startDate,
          endOfDay: new Date(endDate.getTime() + 24 * 60 * 60 * 1000 - 1),
        });
      const result = await query.getRawOne();

      return result;
    } catch (error) {
      throw new HttpException(
        ErrorMessageRevenue[1201],
        ErrorCodeRevenue.ERROR_CALCULATE_REVENUE,
      );
    }
  }

  async calculateRevenueLastSixMonths(): Promise<any> {
    const results = [];
    for (let i = 0; i < 6; i++) {
      const startDate = new Date();
      startDate.setMonth(startDate.getMonth() - i, 1);
      startDate.setHours(0, 0, 0, 0);

      const endDate = new Date(
        startDate.getFullYear(),
        startDate.getMonth() + 1,
        0,
      );

      endDate.setHours(23, 59, 59, 999);
      const revenue = await this.calculateRevenue(startDate, endDate);
      results.push({
        month: startDate.toLocaleString('default', { month: 'long' }),
        totalRevenue: revenue.totalRevenue ?? 0,
      });
    }
    return results.reverse();
  }
}
