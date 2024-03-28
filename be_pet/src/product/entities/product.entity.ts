import { Category } from 'src/category/entities/category.entity';
import { Image } from 'src/image/entities/image.entity';
import { ProductVariant } from 'src/product_variant/entites/product-variant.entity';
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

@Entity('product')
export class Product {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: String })
  name: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column('bigint')
  category_id: number;

  @Column('bigint')
  image_id: number;

  @Column('int', { default: 0 })
  is_best_seller: number;

  @Column('real', { default: 0.0 })
  rating: number;

  @Column('int', { default: 0 })
  sold: number;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @DeleteDateColumn()
  deleted_at: Date;

  @ManyToOne(() => Category, (category) => category.products, {
    onDelete: 'NO ACTION',
    onUpdate: 'NO ACTION',
  })
  @JoinColumn([{ name: 'category_id', referencedColumnName: 'id' }])
  category: Category;

  @ManyToOne(() => Image, (image) => image.products, {
    onDelete: 'NO ACTION',
    onUpdate: 'NO ACTION',
  })
  @JoinColumn([{ name: 'image_id', referencedColumnName: 'id' }])
  image: Image;

  @OneToMany(() => ProductVariant, (productVariant) => productVariant.product)
  product_variants: ProductVariant[];
}
