import { ApiProperty } from '@nestjs/swagger';
import { CreateAddressDto } from './create-address.dto';
import { faker } from '@faker-js/faker';
import { IsNotEmpty, IsNumber, IsOptional, Max, Min } from 'class-validator';
import { Transform, Type } from 'class-transformer';

export class UpdateAddressDto {
  @ApiProperty({
    example: faker.person.fullName(),
    required: true,
  })
  @IsOptional()
  @Type(() => String)
  fullname: string;

  @ApiProperty({
    example: faker.commerce.productName(),
    required: true,
  })
  @IsOptional()
  @Type(() => String)
  ward: string;

  @ApiProperty({
    example: faker.commerce.productName(),
    required: true,
  })
  @IsOptional()
  @Type(() => String)
  district: string;

  @ApiProperty({
    example: faker.commerce.productName(),
    required: true,
  })
  @IsOptional()
  @Type(() => String)
  province: string;

  @ApiProperty({
    example: faker.commerce.productName(),
    required: true,
  })
  @IsOptional()
  @Type(() => String)
  detail_address: string;

  @ApiProperty({
    example: faker.phone.number(),
    required: true,
  })
  @IsOptional()
  @Type(() => String)
  phone_number: string;

  @IsOptional()
  @Transform(({ value }) => parseInt(value))
  @IsNumber()
  @Min(1)
  @Max(1)
  is_active?: 1;
}
