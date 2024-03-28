import { faker } from '@faker-js/faker';
import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsNotEmpty } from 'class-validator';

export class CreateCategoryDto {
  @ApiProperty({
    required: true,
    example: faker.commerce.productName(),
  })
  @IsNotEmpty()
  @Type(() => String)
  name: string;
}
