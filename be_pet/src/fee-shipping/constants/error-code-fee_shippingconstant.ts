export enum ErrorCodeFeeShipping {
  ERROR_GET_PROVINCE_DATA = 1101,
  PROVINCE_ID_NOT_FOUND = 1102,
  ERROR_GET_DISTRICT_DATA = 1103,
  DISTRICT_ID_NOT_FOUND = 1104,
  ERROR_GET_WARD_DATA = 1105,
  WARD_ID_NOT_FOUND = 1106,
  ERROR_CALCULATE_FEE_SHIPPING = 1107,
  ERROR_CREATE_ORDER_GHN = 1108,
}
export const ErrorMessageFeeShipping = {
  1101: 'Không thể lấy dữ liệu tỉnh/thành phố',
  1102: 'Không tìm thấy tên tỉnh/thành phố',
  1103: 'Không thể lấy dữ liệu quận/huyện',
  1104: 'Không tìm thấy tên quận/huyện',
  1105: 'Không thể lấy dữ liệu xã/phường',
  1106: 'Không tìm thấy tên xã/phường',
  1107: 'Không thể tính phí vận chuyển',
  1108: ' Có lỗi xảy ra khi tạo đơn hàng GHN',
};
