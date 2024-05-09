import { ItemsGHN } from 'src/order/interface/items-GHN.interface';

export class CalculateFeeShippingDto {
  from_province_name: string;
  from_district_name: string;
  from_ward_name: string;
  to_province_name: string;
  to_district_name: string;
  to_ward_name: string;
  weight: number;
  items: ItemsGHN[];
}
