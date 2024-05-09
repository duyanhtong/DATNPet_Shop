class CartItemDto {
  id: number;
  product_variant_id: number;
  product_name: string;
  product_variant_name: string;
  image: string;
  price: number;
  promotion: number;
  quantity: number;
}

export class MailConfirmOrderDto {
  id: number;
  user_id: number;
  full_name: string;
  phone_number: string;
  email: string;
  note: string | null;
  status: string;
  payment_method: string;
  total_money: number;
  fee_shipping: number;
  province: string;
  district: string;
  ward: string;
  detail_address: string;
  expected_shipping_date: Date;
  actual_shipping_date: Date;
  order_created_date: Date;
  cartItems: CartItemDto[];
}
