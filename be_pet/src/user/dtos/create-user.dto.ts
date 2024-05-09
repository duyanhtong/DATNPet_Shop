import { faker } from '@faker-js/faker';
import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsEmail, IsNotEmpty } from 'class-validator';

export class RegisterUserDto {
  @ApiProperty({
    required: true,
    example: faker.internet.email(),
  })
  @IsNotEmpty()
  @Type(() => String)
  @IsEmail()
  email: string;

  @ApiProperty({
    required: true,
    example: faker.internet.password(),
  })
  @IsNotEmpty()
  @Type(() => String)
  password: string;

  @ApiProperty({
    required: true,
    example: faker.internet.password(),
  })
  @IsNotEmpty()
  @Type(() => String)
  rePassword: string;
}
