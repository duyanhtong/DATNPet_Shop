import { Product } from 'src/product/entities/product.entity';
import { ProductVariant } from 'src/product_variant/entites/product-variant.entity';
import {
  Column,
  CreateDateColumn,
  DeleteDateColumn,
  Entity,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('image')
export class Image {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: String })
  path: string;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @DeleteDateColumn()
  deleted_at: Date;

  @OneToMany(() => Product, (product) => product.image)
  products: Product[];

  @OneToMany(() => ProductVariant, (productVariant) => productVariant.image)
  productVariants: ProductVariant[];
}
