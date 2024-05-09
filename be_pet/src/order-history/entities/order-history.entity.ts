import { Order } from 'src/order/entities/order.entity';
import {
  Column,
  CreateDateColumn,
  DeleteDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('order_history')
export class OrderHistory {
  @PrimaryGeneratedColumn()
  id: number;

  @Column('bigint', { nullable: false })
  order_id: number;

  @Column('bigint', { nullable: false })
  product_variant_id: number;

  @Column('varchar')
  product_name: string;

  @Column('varchar')
  product_variant_name: string;

  @Column('text')
  image: string;

  @Column('int')
  quantity: number;

  @Column('float')
  price_at_purchase: number;

  @Column('float')
  weight: number;

  @Column('float')
  promotion_at_purchase: number;

  @ManyToOne(() => Order, (order) => order.orderHistories, {
    onDelete: 'NO ACTION',
    onUpdate: 'NO ACTION',
  })
  @JoinColumn([{ name: 'order_id', referencedColumnName: 'id' }])
  order: Order;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @DeleteDateColumn()
  deleted_at: Date;
}
