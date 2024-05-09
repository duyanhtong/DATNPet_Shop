import { faker } from '@faker-js/faker';
import { ApiProperty } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import { IsNumber } from 'class-validator';

export class CreateWishListDto {
  @ApiProperty({
    example: faker.number.int(),
    required: true,
  })
  @Transform(({ value }) => parseInt(value))
  @Type(() => Number)
  @IsNumber()
  product_id: number;
}
