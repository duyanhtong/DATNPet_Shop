import { ProductVariant } from 'src/product_variant/entites/product-variant.entity';
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

@Entity('cart_item')
export class CartItem {
  @PrimaryGeneratedColumn()
  id: number;

  @Column('bigint')
  user_id: number;

  @Column('bigint', { nullable: true })
  order_id: number;

  @Column('bigint')
  product_variant_id: number;

  @Column('int')
  quantity: number;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @DeleteDateColumn()
  deleted_at: Date;

  @ManyToOne(
    () => ProductVariant,
    (productVariant) => productVariant.cartItems,
    {
      onDelete: 'NO ACTION',
      onUpdate: 'NO ACTION',
    },
  )
  @JoinColumn([{ name: 'product_variant_id', referencedColumnName: 'id' }])
  productVariant: ProductVariant;
}
