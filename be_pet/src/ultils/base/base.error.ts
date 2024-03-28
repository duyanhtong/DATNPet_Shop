import { HttpException } from '@nestjs/common';

export default class BaseError extends HttpException {
  code: any;

  getCode() {
    return this.code;
  }

  getMessage() {
    return this.message;
  }
}
