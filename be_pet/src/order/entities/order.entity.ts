import {
  Column,
  CreateDateColumn,
  DeleteDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { CartItem } from 'src/cart_item/entities/cart-item.entity';
import { User } from 'src/user/entities/user.entity';
import { OrderHistory } from 'src/order-history/entities/order-history.entity';

@Entity('order')
export class Order {
  @PrimaryGeneratedColumn()
  id: number;

  @Column('bigint', { nullable: false })
  user_id: number;

  @Column('text', { nullable: true })
  note: string;

  @Column('varchar', { nullable: true })
  order_code: string;

  @Column('varchar')
  status: string;

  @Column('varchar', { default: 'COD' })
  payment_method: string;

  @Column('float', { name: 'total_money' })
  total_money: number;

  @Column('float')
  fee_shipping: number;

  @Column('float')
  total_weight: number;

  @Column('varchar', { name: 'province', nullable: false, length: 100 })
  province: string;

  @Column('varchar', { name: 'district', nullable: false, length: 100 })
  district: string;

  @Column('varchar', { name: 'ward', nullable: false, length: 100 })
  ward: string;

  @Column('varchar', { name: 'detail_address', nullable: false, length: 500 })
  detail_address: string;

  @Column('varchar', {
    name: 'phone_number',
    length: 20,
  })
  phone_number: string;

  @Column('varchar', { nullable: true })
  fullname: string;

  @Column('timestamp', { nullable: true })
  expected_shipping_date: Date;

  @Column('timestamp', { nullable: true })
  actual_shipping_date: Date;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @DeleteDateColumn()
  deleted_at: Date;

  @OneToMany(() => CartItem, (cartItem) => cartItem.order)
  cartItems: CartItem[];

  @OneToMany(() => OrderHistory, (orderHistory) => orderHistory.order)
  orderHistories: OrderHistory[];

  @ManyToOne(() => User, (user) => user.orders, {
    onDelete: 'NO ACTION',
    onUpdate: 'NO ACTION',
  })
  @JoinColumn([{ name: 'user_id', referencedColumnName: 'id' }])
  user: User;
}
