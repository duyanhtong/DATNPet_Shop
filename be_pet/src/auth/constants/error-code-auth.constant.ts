export enum ErrorCodeAuth {
  ERROR_GENERATE_TOKEN = 301,
  INVALID_TOKEN = 302,
  FORBIDDEN_RESOURCE = 303,
}
export const ErrorMessageAuth = {
  301: 'Lỗi tạo token',
  302: 'Token không đúng',
  303: 'không có quyền truy cập vào hệ thống',
};