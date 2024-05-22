export interface ProductFilterType {
  items_per_page?: number;
  category_id?: number;
  page?: number;
  search?: string;
  sort_by?: string;
  order_by?: string;
  is_best_seller?: 0 | 1;
}
