import { Entity, PrimaryColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { AdministrativeUnit } from './administrative_units.entity';
import { District } from './districts.entity';

@Entity('wards')
export class Ward {
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

  @Column({ name: 'district_code', nullable: true })
  district_code: string;

  @ManyToOne(() => AdministrativeUnit)
  @JoinColumn({ name: 'administrative_unit_id' })
  administrativeUnit: AdministrativeUnit;

  @ManyToOne(() => District)
  @JoinColumn({ name: 'district_code' })
  district: District;
}
