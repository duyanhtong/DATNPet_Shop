import {
  Column,
  CreateDateColumn,
  DeleteDateColumn,
  Entity,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('feedback')
export class Feedback {
  @PrimaryGeneratedColumn()
  id: number;

  @Column('bigint', { nullable: false })
  user_id: number;

  @Column('bigint', { nullable: false })
  order_id: number;

  @Column('bigint', { nullable: false })
  product_variant_id: number;

  @Column('float', { nullable: true })
  rating: number;

  @Column('int', { nullable: true })
  comment: string;

  @Column('text', { nullable: true })
  image: string;

  @Column('varchar')
  status: string;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @DeleteDateColumn()
  deleted_at: Date;
}
