export enum ErrorCodeAddress {
  ADDRESS_NOT_FOUND = 901,
  ADDRESS_NOT_DELETE = 902,
  ADDRESS_NOT_DEFAULT = 903,
}
export const ErrorMessageAddress = {
  901: 'Địa chỉ không tồn tại.',
  902: 'Không thể xoá địa chỉ mặc định. \nHãy chọn mặc định một địa chỉ khác và thử lại thao tác.',
  903: 'Bạn chưa có địa chỉ mặc định.',
};
