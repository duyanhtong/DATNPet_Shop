import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity('administrative_regions')
export class AdministrativeRegion {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  name: string;

  @Column({ name: 'name_en' })
  nameEn: string;

  @Column({ name: 'code_name', nullable: true })
  codeName: string;

  @Column({ name: 'code_name_en', nullable: true })
  codeNameEn: string;
}
