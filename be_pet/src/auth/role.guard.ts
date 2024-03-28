import {
  CanActivate,
  ExecutionContext,
  Injectable,
  ForbiddenException,
  HttpException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import {
  ErrorCodeAuth,
  ErrorMessageAuth,
} from './constants/error-code-auth.constant';

@Injectable()
export class RoleGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const requireRoles = this.reflector.getAllAndOverride<string[]>('role', [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!requireRoles) {
      return true;
    }
    const { account } = context.switchToHttp().getRequest();
    if (!account || !account.role) {
      throw new HttpException(
        ErrorMessageAuth[303],
        ErrorCodeAuth.FORBIDDEN_RESOURCE,
      );
    }
    return requireRoles.includes(account.role);
  }
}
