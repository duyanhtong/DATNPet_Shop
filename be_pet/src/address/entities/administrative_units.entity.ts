import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity('administrative_units')
export class AdministrativeUnit {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'full_name', nullable: true })
  fullName: string;

  @Column({ name: 'full_name_en', nullable: true })
  fullNameEn: string;

  @Column({ name: 'short_name', nullable: true })
  shortName: string;

  @Column({ name: 'short_name_en', nullable: true })
  shortNameEn: string;

  @Column({ name: 'code_name', nullable: true })
  codeName: string;

  @Column({ name: 'code_name_en', nullable: true })
  codeNameEn: string;
}
