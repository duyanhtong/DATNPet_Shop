import { Entity, PrimaryColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { AdministrativeUnit } from './administrative_units.entity';
import { Province } from './provinces.entity';

@Entity('districts')
export class District {
  @PrimaryColumn()
  code: string;

  @Column()
  name: string;

  @Column({ name: 'name_en', nullable: true })
  nameEn: string;

  @Column({ name: 'full_name', nullable: true })
  fullName: string;

  @Column({ name: 'full_name_en', nullable: true })
  fullNameEn: string;

  @Column({ name: 'code_name', nullable: true })
  codeName: string;

  @Column({ name: 'province_code', nullable: true })
  province_code: string;

  @ManyToOne(() => AdministrativeUnit)
  @JoinColumn({ name: 'administrative_unit_id' })
  administrativeUnit: AdministrativeUnit;

  @ManyToOne(() => Province)
  @JoinColumn({ name: 'province_code' })
  province: Province;
}
