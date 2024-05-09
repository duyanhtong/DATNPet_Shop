import {
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';
import { CalculateFeeShippingDto } from './fee-shipping.calculate.dto';

export class CreateOrderGHNDTO extends CalculateFeeShippingDto {
  @IsString()
  @IsNotEmpty()
  name_user: string;

  @IsString()
  @IsNotEmpty()
  phone_user: string;

  @IsString()
  @IsNotEmpty()
  address_detail_user: string;

  @IsNotEmpty()
  @IsNumber()
  @Min(0)
  feeShipping: number;

  @IsNotEmpty()
  @IsNumber()
  @Min(0)
  totalMoney: number;

  @IsString()
  @IsOptional()
  note: string;
}
