import { faker } from '@faker-js/faker';
import { ApiProperty } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import { IsNotEmpty, IsNumber, IsOptional, Max, Min } from 'class-validator';

export class CreateProductVariantDto {
  @ApiProperty({
    example: faker.commerce.productName(),
    required: true,
  })
  @IsNotEmpty()
  @Type(() => String)
  name: string;

  @ApiProperty({
    example: 'SP001',
    required: true,
  })
  @IsOptional()
  @Type(() => String)
  product_code: string;

  @Transform(({ value }) => parseInt(value))
  @Type(() => Number)
  @IsNumber()
  @IsNotEmpty()
  product_id: number;

  @Transform(({ value }) => parseInt(value))
  @Type(() => Number)
  @IsNumber()
  @IsNotEmpty()
  weight: number;

  @Transform(({ value }) => parseInt(value))
  @Type(() => Number)
  @IsNumber()
  @IsNotEmpty()
  price: number;

  @Transform(({ value }) => parseInt(value))
  @Type(() => Number)
  @IsOptional()
  @IsNumber()
  @Max(90)
  discount_rate: number;

  @Transform(({ value }) => parseInt(value))
  @Type(() => Number)
  @IsNotEmpty()
  @IsNumber()
  @Min(0)
  inventory: number;
}
