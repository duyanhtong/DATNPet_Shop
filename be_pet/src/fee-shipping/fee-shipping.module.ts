import { Module } from '@nestjs/common';
import { FeeShippingService } from './fee-shipping.service';
import { FeeShippingController } from './fee-shipping.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Order } from 'src/order/entities/order.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Order])],
  controllers: [FeeShippingController],
  providers: [FeeShippingService],
})
export class FeeShippingModule {}
