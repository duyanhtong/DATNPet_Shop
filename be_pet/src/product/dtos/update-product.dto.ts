import { faker } from '@faker-js/faker';
import { ApiProperty } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import {
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';

export class UpdateProductDto {
  @ApiProperty({
    example: faker.commerce.productName(),
    required: true,
  })
  @IsOptional()
  @IsString()
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
  @IsOptional()
  @Transform(({ value }) => parseInt(value))
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  @Max(1)
  is_best_seller: number;

  @ApiProperty({
    example: faker.number.int(),
    required: true,
  })
  @Transform(({ value }) => parseInt(value))
  @Type(() => Number)
  @IsOptional()
  @IsNumber()
  category_id: number;
}
