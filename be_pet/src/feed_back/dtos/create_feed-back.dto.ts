import { IsNotEmpty, IsNumber, IsOptional, IsString } from 'class-validator';

export class CreateFeedbackDto {
  @IsNotEmpty()
  @IsNumber()
  user_id: number;

  @IsNumber()
  @IsNotEmpty()
  product_variant_id: number;

  @IsNumber()
  @IsNotEmpty()
  order_id: number;
}
