import { faker } from '@faker-js/faker';
import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsNotEmpty, IsOptional } from 'class-validator';

export class CreateAddressDto {
  @ApiProperty({
    example: faker.person.fullName(),
    required: true,
  })
  @IsNotEmpty()
  @Type(() => String)
  fullname: string;

  @ApiProperty({
    example: faker.commerce.productName(),
    required: true,
  })
  @IsNotEmpty()
  @Type(() => String)
  ward: string;

  @ApiProperty({
    example: faker.commerce.productName(),
    required: true,
  })
  @IsNotEmpty()
  @Type(() => String)
  district: string;

  @ApiProperty({
    example: faker.commerce.productName(),
    required: true,
  })
  @IsNotEmpty()
  @Type(() => String)
  province: string;

  @ApiProperty({
    example: faker.commerce.productName(),
    required: true,
  })
  @IsNotEmpty()
  @Type(() => String)
  detail_address: string;

  @ApiProperty({
    example: faker.phone.number(),
    required: true,
  })
  @IsNotEmpty()
  @Type(() => String)
  phone_number: string;
}
