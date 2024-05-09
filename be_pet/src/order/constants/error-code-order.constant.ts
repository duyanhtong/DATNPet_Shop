export enum ErrorCodeOrder {
  INVENTORY_PRODUCT_NOT_ENOUGH = 1101,
  ORDER_NOT_FOUND = 1102,
  ORDER_CANNOT_BE_CANCEL = 1103,
}
export const ErrorMessageOrder = {
  1101: 'Số lượng mua không đủ trong kho',
  1102: 'Không tìm thấy đơn hàng',
  1103: 'Không thể huỷ đơn hàng khi người bán đã xác nhận đơn hàng.',
};
