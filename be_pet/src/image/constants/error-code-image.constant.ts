export enum ErrorCodeImage {
  FILE_SIZE_EXCEED = 501,
  INVALID_IMAGE_FILE = 502,
  S3_UPLOAD_ERROR = 503,
}
export const ErrorMessageImage = {
  501: 'Kích thước tệp vượt quá giới hạn 5MB',
  502: 'File không đúng định dạng',
  503: 'Lỗi tải ảnh lên server s3',
};
