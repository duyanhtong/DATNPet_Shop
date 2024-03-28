import {
  PipeTransform,
  Injectable,
  ArgumentMetadata,
  BadRequestException,
  HttpStatus,
} from '@nestjs/common';
import { validate, ValidationError } from 'class-validator';
import { plainToClass } from 'class-transformer';
import { ErrorCode } from '../base/error-code.base';

@Injectable()
export class CustomValidationPipe implements PipeTransform<any> {
  async transform(value: any, metadata: ArgumentMetadata): Promise<any> {
    const { metatype } = metadata;

    if (!metatype || !this.toValidate(metatype)) {
      return value;
    }

    const object = plainToClass(metatype, value);
    const errors: ValidationError[] = await validate(object);

    if (errors.length > 0) {
      const errorDetails = errors.map((error) => {
        let errorMessage = Object.values(error.constraints)[0];
        let errorType = 'validate';
        let statusCode = this.mapErrorCodeToStatusCode(error.constraints);

        return {
          property: error.property,
          message: errorMessage,
          errorType,
          statusCode,
        };
      });

      throw new BadRequestException({
        success: 0,
        data: {
          status: errorDetails[0].statusCode,
          message: errorDetails[0].message,
          property: errorDetails[0].property,
          errorType: errorDetails[0].errorType,
        },
      });
    }

    return value;
  }

  private toValidate(metatype: Function): boolean {
    const types: Function[] = [String, Boolean, Number, Array, Object];
    return !types.includes(metatype);
  }

  private mapErrorCodeToStatusCode(constraints: any): number {
    switch (Object.keys(constraints)[0]) {
      case 'isNumber':
        return ErrorCode.MUST_BE_A_NUMBER;
      case 'min':
        return ErrorCode.SMALL_VALUE;
      case 'isString':
        return ErrorCode.MUST_BE_A_STRING;
      case 'max':
        return ErrorCode.BIG_VALUE;
      case 'isNotEmpty':
        return ErrorCode.VALUE_IS_EMPTY;
      case 'isEmail':
        return ErrorCode.EMAIL_NOT_VALID;
      case 'notEquals':
        return ErrorCode.VALUE_IS_EMPTY;
      default:
        return 400;
    }
  }
}
