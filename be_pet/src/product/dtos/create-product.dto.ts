import { faker } from '@faker-js/faker';
import { ApiProperty } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import { IsNotEmpty, IsNumber, IsOptional, IsString } from 'class-validator';

export class CreateProductDto {
  @ApiProperty({
    example: faker.commerce.productName(),
    required: true,
  })
  @IsNotEmpty()
  @Type(() => String)
  name: string;

  @ApiProperty({
    example: faker.commerce.productDescription(),
    required: true,
  })
  @IsOptional()
  @IsString()
  @Type(() => String)
  description: string;

  @ApiProperty({
    example: faker.number.int(),
    required: true,
  })
  @Transform(({ value }) => parseInt(value))
  @Type(() => Number)
  @IsNumber()
  category_id: number;
}
