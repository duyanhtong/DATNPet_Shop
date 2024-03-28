import {
  CanActivate,
  ExecutionContext,
  HttpException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Reflector } from '@nestjs/core';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { extractTokenFromHeader } from 'src/ultils/helpers/extractTokenFromHeader';
import { User } from 'src/user/entities/user.entity';

import { Repository } from 'typeorm';
import {
  ErrorCodeAuth,
  ErrorMessageAuth,
} from './constants/error-code-auth.constant';

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(
    @InjectRepository(User) private readonly userRepository: Repository<User>,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly reflector: Reflector,
  ) {}
  async canActivate(context: ExecutionContext): Promise<boolean> {
    const isPublic = this.reflector.getAllAndOverride<string[]>('isPublic', [
      context.getHandler(),
      context.getClass(),
    ]);

    if (isPublic) {
      return true;
    }

    const request = context.switchToHttp().getRequest();

    const token = await extractTokenFromHeader(request);

    if (!token) {
      throw new HttpException(
        ErrorMessageAuth[303],
        ErrorCodeAuth.FORBIDDEN_RESOURCE,
      );
    }

    try {
      const payload = await this.jwtService.verifyAsync(token, {
        secret: this.configService.get<string>('ACCESS_TOKEN_KEY'),
      });
      if (!payload) {
        throw new HttpException(
          ErrorMessageAuth[303],
          ErrorCodeAuth.FORBIDDEN_RESOURCE,
        );
      }
      //request['user_data'] = payload;
      const user = await this.userRepository.findOne({
        where: { id: payload.id },
      });

      if (!user) {
        throw new HttpException(
          ErrorMessageAuth[302],
          ErrorCodeAuth.INVALID_TOKEN,
        );
      }
      request['account'] = user;
    } catch (error) {
      throw new HttpException(
        ErrorMessageAuth[302],
        ErrorCodeAuth.INVALID_TOKEN,
      );
    }
    return true;
  }
}
