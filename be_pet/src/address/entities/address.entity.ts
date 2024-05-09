import { User } from 'src/user/entities/user.entity';
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

@Entity('address')
export class Address {
  @PrimaryGeneratedColumn()
  id: number;

  @Column('bigint')
  user_id: number;

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

  @Column('int', { default: 0 })
  is_active: number;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @DeleteDateColumn()
  deleted_at: Date;

  @ManyToOne(() => User, (user) => user.addresses, {
    onDelete: 'NO ACTION',
    onUpdate: 'NO ACTION',
  })
  @JoinColumn([{ name: 'user_id', referencedColumnName: 'id' }])
  user: User;
}
