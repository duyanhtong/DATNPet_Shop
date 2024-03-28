import { Token } from 'src/token/entities/token.entity';
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
}
