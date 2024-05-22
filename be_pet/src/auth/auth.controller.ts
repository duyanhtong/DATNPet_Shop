import {
  Body,
  Controller,
  Post,
  Req,
  Request,
  UseGuards,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import BaseController from 'src/ultils/base/response.base';
import { RegisterUserDto } from 'src/user/dtos/create-user.dto';
import { ValidateDto } from 'src/ultils/decorators/pipe-validate.decorator';
import CommonError from 'src/ultils/base/error-code.base';
import { LoginDto } from './dtos/login-auth.dto';
import { access } from 'fs';
import { Public } from './decorators/public.decorator';
import { AuthGuard } from '@nestjs/passport';
import { JwtAuthReq } from './decorators/strategy.decorator';

@Controller('auth')
export class AuthController extends BaseController {
  constructor(private readonly authService: AuthService) {
    super();
  }

  @ValidateDto()
  @Public()
  @Post('register')
  async register(@Body() body: RegisterUserDto): Promise<any> {
    try {
      console.log('run api register');
      const result = await this.authService.register(body);
      if (result instanceof CommonError) {
        throw result;
      }
      return this.data(result);
    } catch (error) {
      if (error instanceof CommonError) return error;
      return this.fail(error);
    }
  }

  @ValidateDto()
  @Public()
  @Post('login')
  async login(@Body() body: LoginDto): Promise<any> {
    try {
      console.log('run api login');
      const result = await this.authService.login(body);
      if (result instanceof CommonError) {
        throw result;
      }
      return this.data(result);
    } catch (error) {
      if (error instanceof CommonError) return error;
      return this.fail(error);
    }
  }

  @Public()
  @Post('refresh')
  async refresh(@Body('refreshToken') refreshToken: string): Promise<any> {
    try {
      const result = await this.authService.refresh(refreshToken);
      if (result instanceof CommonError) {
        throw result;
      }
      return this.data(result);
    } catch (error) {
      if (error instanceof CommonError) return error;
      return this.fail(error);
    }
  }

  @JwtAuthReq()
  @Post('profile')
  async profile(@Request() req: any): Promise<any> {
    try {
      const result = await this.authService.profile(req.user);
      if (result instanceof CommonError) {
        throw result;
      }
      return this.data(result);
    } catch (error) {
      if (error instanceof CommonError) return error;
      return this.fail(error);
    }
  }
}
