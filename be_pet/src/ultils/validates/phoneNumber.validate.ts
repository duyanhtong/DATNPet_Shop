import { HttpException, HttpStatus } from '@nestjs/common';
import { ErrorCode, ErrorMessage } from '../base/error-code.base';

export async function isValidPhoneNumber(phoneNumber: string): Promise<void> {
  const phoneRegex = /^(?:\+84[0-9]{9}|0[0-9]{9,10})$/;

  if (!phoneRegex.test(phoneNumber)) {
    throw new HttpException(
      ErrorMessage[103],
      ErrorCode.INVALID_PHONENUMBER_FORMAT,
    );
  }
}
