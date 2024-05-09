import { HttpException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Address } from './entities/address.entity';
import { Brackets, Repository } from 'typeorm';
import { User } from 'src/user/entities/user.entity';
import { CreateAddressDto } from './dtos/create-address.dto';
import { UpdateAddressDto } from './dtos/update-address.dto';
import {
  ErrorCodeAddress,
  ErrorMessageAddress,
} from './constants/error-code-cart_item.constant';
import { AddressFilterType } from './interfaces/address.filter-type.interface';
import { SORT_BY_ADDRESS } from './constants/address.sort-by.constant';
import { Province } from './entities/provinces.entity';
import { District } from './entities/districts.entity';
import { Ward } from './entities/wards.entity';
import { isValidPhoneNumber } from 'src/ultils/validates/phoneNumber.validate';

@Injectable()
export class AddressService {
  constructor(
    @InjectRepository(Address)
    private readonly addressRepository: Repository<Address>,
    @InjectRepository(User) private readonly userRepositoy: Repository<User>,
    @InjectRepository(Province)
    private readonly provinceRepositoy: Repository<Province>,
    @InjectRepository(District)
    private readonly districtRepositoy: Repository<District>,
    @InjectRepository(Ward)
    private readonly wardRepositoy: Repository<Ward>,
  ) {}

  private async checkAddressId(id: number): Promise<Address> {
    const address = await this.addressRepository.findOne({ where: { id: id } });
    if (!address) {
      throw new HttpException(
        ErrorMessageAddress[901],
        ErrorCodeAddress.ADDRESS_NOT_FOUND,
      );
    }
    return address;
  }

  private async countAddress(userId: number): Promise<number> {
    const count = await this.addressRepository.count({
      where: { user_id: userId },
    });
    return count;
  }

  async create(user: User, data: CreateAddressDto): Promise<any> {
    const hasExistingAddresses = (await this.countAddress(user.id)) > 0;
    await isValidPhoneNumber(data.phone_number);
    const newAddress = this.addressRepository.create({
      user_id: user.id,
      fullname: data.fullname,
      province: data.province,
      district: data.district,
      ward: data.ward,
      detail_address: data.detail_address,
      phone_number: data.phone_number,
      is_active: hasExistingAddresses ? 0 : 1,
    });

    await this.addressRepository.save(newAddress);

    return this.getOneAddressOption(newAddress);
  }

  async getAddressDefault(userId: number): Promise<Address> {
    const address = await this.addressRepository.findOne({
      where: { user_id: userId, is_active: 1 },
    });
    if (!address) {
      throw new HttpException(
        ErrorMessageAddress[903],
        ErrorCodeAddress.ADDRESS_NOT_DEFAULT,
      );
    }
    return address;
  }

  async getAddressDefaultMe(userId: number): Promise<Address> {
    const address = await this.addressRepository.findOne({
      where: { user_id: userId, is_active: 1 },
    });
    if (!address) {
      throw new HttpException(
        ErrorMessageAddress[903],
        ErrorCodeAddress.ADDRESS_NOT_DEFAULT,
      );
    }
    return await this.getOneAddressOption(address);
  }

  async update(id: number, data: UpdateAddressDto): Promise<any> {
    const address = await this.checkAddressId(id);

    if (data.phone_number && data.phone_number != address.phone_number) {
      await isValidPhoneNumber(data.phone_number);
      address.phone_number = data.phone_number;
    }

    address.fullname =
      data.fullname != undefined ? data.fullname : address.fullname;
    address.province =
      data.province != undefined ? data.province : address.province;
    address.district =
      data.district != undefined ? data.district : address.district;
    address.ward = data.ward != undefined ? data.ward : address.ward;
    address.detail_address =
      data.detail_address != undefined
        ? data.detail_address
        : address.detail_address;

    if (data.is_active !== undefined && !isNaN(Number(data.is_active))) {
      const userId = address.user_id;

      await this.addressRepository
        .createQueryBuilder()
        .update()
        .set({ is_active: 0 })
        .where('user_id = :userId', { userId: userId })
        .execute();

      address.is_active = Number(data.is_active);
    }

    await this.addressRepository.save(address);
    return await this.getOneAddressOption(address);
  }

  async updateAddressMe(user: User, data: UpdateAddressDto): Promise<any> {
    const address = await this.getAddressDefault(user.id);
    return await this.update(address.id, data);
  }

  async getDetail(id: number): Promise<any> {
    const address = await this.checkAddressId(id);
    await this.addressRepository.save(address);
    return await this.getOneAddressOption(address);
  }

  async remove(id: number): Promise<any> {
    const address = await this.checkAddressId(id);
    if (address.is_active == 1) {
      throw new HttpException(
        ErrorMessageAddress[902],
        ErrorCodeAddress.ADDRESS_NOT_DELETE,
      );
    }
    await this.addressRepository.softDelete(id);
    return {
      message: 'Xoá thành công địa chỉ. ',
      address,
    };
  }

  async getList(user: User, filter: AddressFilterType): Promise<any> {
    let itemsPerPage: number = Number(filter.items_per_page) || 10;
    if (itemsPerPage > 50) {
      itemsPerPage = 50;
    }
    const page: number = filter.page || 1;
    const search: string = filter.search || '';
    const skip = page - 1 ? (page - 1) * itemsPerPage : 0;
    let sort_by: string = filter.sort_by || 'created_at';
    const order_by = filter.order_by?.toLowerCase() === 'desc' ? 'DESC' : 'ASC';
    if (!SORT_BY_ADDRESS.includes(sort_by)) {
      sort_by = 'created_at';
    }
    const user_id: number = user.id;

    const query = this.addressRepository.createQueryBuilder('address');
    query.andWhere(
      new Brackets((qb) => {
        qb.where('address.user_id  =:user_id', { user_id });
      }),
    );
    if (search) {
      query.andWhere(
        new Brackets((qb) => {
          qb.where('address.ward LIKE :search', {
            search: `%${search}%`,
          })
            .orWhere('address.district LIKE :search', {
              search: `%${search}%`,
            })
            .orWhere('address.province LIKE :search', {
              search: `%${search}%`,
            })
            .orWhere('address.provphone_numberince LIKE :search', {
              search: `%${search}%`,
            })
            .orWhere('address.detail_address LIKE :search', {
              search: `%${search}%`,
            })
            .orWhere('address.fullname LIKE :search', {
              search: `%${search}%`,
            });
        }),
      );
    }

    query.orderBy(`address.${sort_by}`, order_by);
    query.skip(skip);
    query.take(itemsPerPage);
    const [data, total] = await query.getManyAndCount();
    const addressOptions = await this.getListAddressOption(data);
    return {
      addresses: addressOptions,
      total: total,
    };
  }

  private async getOneAddressOption(address: Address): Promise<any> {
    return {
      id: address.id,
      user_id: address.user_id,
      fullname: address.fullname,
      province: address.province,
      district: address.district,
      ward: address.ward,
      detail_address: address.detail_address,
      phone_number: address.phone_number,
      is_active: address.is_active,
    };
  }

  private async getListAddressOption(addresses: Address[]): Promise<any> {
    const addressOptions = await Promise.all(
      addresses.map((address) => this.getOneAddressOption(address)),
    );
    return addressOptions;
  }

  async getAllProvince(): Promise<any> {
    const provinces = await this.provinceRepositoy.find();
    const provinceOption = await this.getListProvinceOption(provinces);
    return provinceOption;
  }

  private async getOneProvinceOption(province: Province): Promise<any> {
    return {
      code: province.code,
      name: province.name,
      nameEn: province.nameEn,
      fullName: province.fullName,
    };
  }

  private async getListProvinceOption(provinces: Province[]): Promise<any> {
    const provinceOption = await Promise.all(
      provinces.map((province) => this.getOneProvinceOption(province)),
    );
    return provinceOption;
  }

  async getAllDistrictByCity(cityCode: string): Promise<any> {
    const districts = await this.districtRepositoy.find({
      where: { province_code: cityCode },
    });
    const districtOptions = await this.getListDistrictOption(districts);
    return districtOptions;
  }

  private async getOneDistrictOption(district: District): Promise<any> {
    return {
      code: district.code,
      name: district.name,
      nameEn: district.nameEn,
      fullName: district.fullName,
    };
  }

  private async getListDistrictOption(districts: District[]): Promise<any> {
    const districtOptions = await Promise.all(
      districts.map((district) => this.getOneDistrictOption(district)),
    );

    return districtOptions;
  }

  async getAllWardByDistrict(districtCode: string): Promise<any> {
    const wards = await this.wardRepositoy.find({
      where: { district_code: districtCode },
    });
    const wardOption = await this.getListWardOption(wards);
    return wardOption;
  }

  private async getOneWardOption(ward: Ward): Promise<any> {
    return {
      code: ward.code,
      name: ward.name,
      nameEn: ward.nameEn,
      fullName: ward.fullName,
    };
  }

  private async getListWardOption(wards: Ward[]): Promise<any> {
    const wardOption = await Promise.all(
      wards.map((ward) => this.getOneWardOption(ward)),
    );
    return wardOption;
  }
}
