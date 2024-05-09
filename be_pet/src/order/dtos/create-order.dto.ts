import { faker } from '@faker-js/faker';
import { ApiProperty } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import { IsNotEmpty, IsNumber, IsOptional, IsArray } from 'class-validator';

export class CreateOrderDto {
  @ApiProperty({
    example: faker.lorem.words(5),
    required: true,
  })
  @IsOptional()
  note: string;

  @ApiProperty({
    example: faker.number.int(),
    required: true,
  })
  @Transform(({ value }) => parseInt(value), { toClassOnly: true })
  @Type(() => Number)
  @IsNumber()
  @IsNotEmpty()
  address_id: number;

  @ApiProperty({
    example: faker.lorem.words(5),
    required: true,
  })
  @IsNotEmpty()
  payment_method: string;

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
  carts: number[];
}
