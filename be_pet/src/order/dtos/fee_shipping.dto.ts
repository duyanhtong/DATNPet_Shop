import { faker } from '@faker-js/faker';
import { ApiProperty } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import { IsArray, IsNotEmpty, IsNumber } from 'class-validator';

export class FeeShippingDto {
  @ApiProperty({
    example: faker.number.int(),
    required: true,
  })
  @Transform(({ value }) => parseInt(value), { toClassOnly: true })
  @Type(() => Number)
  @IsNumber()
  @IsNotEmpty()
  addressId: number;

  @ApiProperty({
    example: [1, 2, 3],
    isArray: true,
    required: true,
  })
  @Transform(({ value }) => (Array.isArray(value) ? value.map(Number) : []), {
    toClassOnly: true,
  })
  @IsArray()
  @IsNumber({}, { each: true })
  @IsNotEmpty()
  cartIds: number[];
}
