import { faker } from '@faker-js/faker';
import { ApiProperty } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import { IsNotEmpty, IsNumber, Min } from 'class-validator';

export class UpdateCartItemDto {
  @ApiProperty({
    example: faker.number.int(),
    required: true,
  })
  @Transform(({ value }) => parseInt(value))
  @Type(() => Number)
  @IsNumber()
  @IsNotEmpty()
  quantity: number;
}
