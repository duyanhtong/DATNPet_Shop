import { HttpException } from '@nestjs/common';
import { ErrorCode, ErrorMessage } from '../base/error-code.base';

export async function isValidEmail(email: string): Promise<void> {
  const emailRegex: RegExp = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

  if (!emailRegex.test(email)) {
    throw new HttpException(ErrorMessage[104], ErrorCode.EMAIL_NOT_VALID);
  }
}
