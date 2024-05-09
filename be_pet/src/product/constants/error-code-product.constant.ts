export enum ErrorCodeProduct {
  PRODUCT_NOT_FOUND = 601,
  PRODUCT_NAME_EXISTS = 602,
  ERROR_GET_TOP_SELLING = 603,
}
export const ErrorMessageProduct = {
  601: 'Sản phẩm không tồn tại',
  602: 'Tên sản phẩm đã tồn tại',
  603: ' Có lỗi khi lấy danh sách Top 5 Sản phẩm bán chạy',
};
