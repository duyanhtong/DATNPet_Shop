import { IsEnum, IsOptional, IsString } from 'class-validator';
import { OrderStatusEnum } from '../constants/order.status.constant';

export class updateStatusOrderDto {
  @IsString()
  @IsOptional()
  @IsEnum(OrderStatusEnum)
  status: string;
}
