import BaseError from './base.error';

export enum ErrorCode {
  PHONE_NUMBER_EXISTS = 101,
  MISSING_PHONENUMBER = 102,
  INVALID_PHONENUMBER_FORMAT = 103,
  EMAIL_NOT_VALID = 104,
  INVALID_TIMESTAMP = 105,
  USER_IS_EMPTY = 106,
  MUST_BE_A_NUMBER = 107,
  SMALL_VALUE = 108,
  MUST_BE_A_STRING = 109,
  BIG_VALUE = 110,
  VALUE_IS_EMPTY = 111,
  EMAIL_EXISTS = 112,
}

export const ErrorMessage = {
  101: 'Số điện thoại đã tồn tại',
  102: 'Số điện thoại không được để trống',
  103: 'Số điện thoại không đúng định dạng',
  104: 'email không đúng định dạng',
  105: 'Invalid timestamp (in milliseconds)',
  106: 'user is empty',
  107: 'value must be a number',
  108: 'value is small',
  109: 'value must be a string',
  110: 'value is small',
  111: 'value is empty',
  112: 'email đã tồn tại',
};

export default class CommonError extends BaseError {
  code: ErrorCode;

  constructor(code: ErrorCode) {
    super(ErrorMessage[code], 400);

    this.name = 'Error';
    this.code = code;
  }
}
