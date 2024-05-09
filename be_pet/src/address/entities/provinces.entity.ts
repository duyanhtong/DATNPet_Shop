import { Entity, PrimaryColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { AdministrativeRegion } from './administrative_regions.entity';
import { AdministrativeUnit } from './administrative_units.entity';

@Entity('provinces')
export class Province {
  @PrimaryColumn()
  code: string;

  @Column()
  name: string;

  @Column({ name: 'name_en', nullable: true })
  nameEn: string;

  @Column({ name: 'full_name' })
  fullName: string;

  @Column({ name: 'full_name_en', nullable: true })
  fullNameEn: string;

  @Column({ name: 'code_name', nullable: true })
  codeName: string;

  @ManyToOne(() => AdministrativeRegion)
  @JoinColumn({ name: 'administrative_region_id' })
  administrativeRegion: AdministrativeRegion;

  @ManyToOne(() => AdministrativeUnit)
  @JoinColumn({ name: 'administrative_unit_id' })
  administrativeUnit: AdministrativeUnit;
}
