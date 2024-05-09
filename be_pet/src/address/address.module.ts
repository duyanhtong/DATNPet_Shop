import { Module } from '@nestjs/common';
import { AddressService } from './address.service';
import { AddressController } from './address.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Address } from './entities/address.entity';
import { User } from 'src/user/entities/user.entity';
import { Province } from './entities/provinces.entity';
import { District } from './entities/districts.entity';
import { Ward } from './entities/wards.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([Address, User, Province, District, Ward]),
  ],
  controllers: [AddressController],
  providers: [AddressService],
})
export class AddressModule {}
