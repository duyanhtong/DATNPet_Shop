export enum ErrorCodeProductVariant {
  PRODUCT_VARIANT_NOT_FOUND = 701,
  PRODUCT_CODE_EXISTS = 702,
  PRODUCT_VARIANT_NAME_EXISTS = 703,
  INVENTORY_NOT_ENOUGH = 704,
}
export const ErrorMessageProductvariant = {
  701: 'Phân loại sản phẩm không tồn tại',
  702: 'Code sản phẩm đã tồn tại',
  703: 'Tên phân loại của sản phẩm đã tồn tại',
  704: 'Số lượng tồn kho không đủ để thực hiện yêu cầu.',
};
