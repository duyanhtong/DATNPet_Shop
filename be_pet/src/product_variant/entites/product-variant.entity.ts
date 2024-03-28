import { CartItem } from 'src/cart_item/entities/cart-item.entity';
import { Image } from 'src/image/entities/image.entity';
import { Product } from 'src/product/entities/product.entity';
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

@Entity('product_variant')
export class ProductVariant {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: String })
  name: string;

  @Column({ type: String, nullable: true })
  product_code: string;

  @Column({ type: 'bigint' })
  product_id: number;

  @Column({ type: 'decimal' })
  price: number;

  @Column({ type: 'int', nullable: true })
  discount_rate: number;

  @Column({ type: 'int' })
  inventory: number;

  @Column('bigint')
  image_id: number;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @DeleteDateColumn()
  deleted_at: Date;

  @ManyToOne(() => Product, (product) => product.product_variants, {
    onDelete: 'NO ACTION',
    onUpdate: 'NO ACTION',
  })
  @JoinColumn([{ name: 'product_id', referencedColumnName: 'id' }])
  product: Product;

  @ManyToOne(() => Image, (image) => image.productVariants, {
    onDelete: 'NO ACTION',
    onUpdate: 'NO ACTION',
  })
  @JoinColumn([{ name: 'image_id', referencedColumnName: 'id' }])
  image: Image;

  @OneToMany(() => CartItem, (cartItem) => cartItem.productVariant)
  cartItems: CartItem[];
}
