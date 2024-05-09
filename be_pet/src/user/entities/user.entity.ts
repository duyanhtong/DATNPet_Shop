import { Address } from 'src/address/entities/address.entity';
import { Order } from 'src/order/entities/order.entity';
import { Token } from 'src/token/entities/token.entity';
import { WishList } from 'src/wish_list/entities/wish-list.entity';
import {
  Column,
  CreateDateColumn,
  DeleteDateColumn,
  Entity,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('user')
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: String, unique: true })
  email: string;

  @Column('varchar', { name: 'password' })
  password: string;

  @Column('varchar', { name: 'image' })
  image: string;

  @Column('varchar', { name: 'role', length: 10 })
  role: string;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @DeleteDateColumn()
  deleted_at: Date;

  @OneToMany(() => Token, (token) => token.user)
  tokens: Token[];

  @OneToMany(() => Address, (address) => address.user)
  addresses: Address[];

  @OneToMany(() => WishList, (wishList) => wishList.user)
  wishLists: WishList[];

  @OneToMany(() => Order, (order) => order.user)
  orders: Order[];
}
