import { HttpException, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Token } from 'src/token/entities/token.entity';
import { ErrorCode, ErrorMessage } from 'src/ultils/base/error-code.base';
import { isValidEmail } from 'src/ultils/validates/email.validate';
import {
  ErrorCodeUser,
  ErrorMessageUser,
} from 'src/user/constants/error-code-user.constant';
import { RegisterUserDto } from 'src/user/dtos/create-user.dto';
import { User } from 'src/user/entities/user.entity';
import { Repository } from 'typeorm';
import { hash, compare } from 'bcryptjs';
import { LoginDto } from './dtos/login-auth.dto';
import {
  ErrorCodeAuth,
  ErrorMessageAuth,
} from './constants/error-code-auth.constant';
import { FeeShippingService } from 'src/fee-shipping/fee-shipping.service';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User) private readonly userRepository: Repository<User>,
    @InjectRepository(Token)
    private readonly tokenRepository: Repository<Token>,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly feeShippingService: FeeShippingService,
  ) {}

  private async checkEmailExists(email: string): Promise<void> {
    const user = await this.userRepository.findOne({ where: { email: email } });
    if (user) {
      throw new HttpException(ErrorMessage[112], ErrorCode.EMAIL_EXISTS);
    }
  }

  private async getUserById(id: number): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id: id } });
    if (!user) {
      throw new HttpException(
        ErrorMessageAuth[302],
        ErrorCodeAuth.INVALID_TOKEN,
      );
    }
    return user;
  }

  async register(data: RegisterUserDto): Promise<any> {
    await isValidEmail(data.email);
    await this.checkEmailExists(data.email);
    if (data.password !== data.rePassword) {
      throw new HttpException(
        ErrorMessageUser[201],
        ErrorCodeUser.REPASSWORD_IS_NOT_CORRECT,
      );
    }

    const hashPassword = await hash(data.password, 10);
    const user = await this.userRepository.create({
      email: data.email,
      password: hashPassword,
      image: this.configService.get<string>('AWS_IMAGE_DEFAULT'),
      role: 'user',
    });
    await this.userRepository.save(user);
    return await this.getOneUserOption(user);
  }

  private async getUserByEmail(email: string): Promise<User> {
    const user = await this.userRepository.findOne({ where: { email: email } });
    if (!user) {
      throw new HttpException(
        ErrorMessageUser[202],
        ErrorCodeUser.USER_NOT_FOUND,
      );
    }
    return user;
  }

  async login(data: LoginDto): Promise<any> {
    const user = await this.getUserByEmail(data.email);
    const verifyPassword = await compare(data.password, user.password);
    if (!verifyPassword) {
      throw new HttpException(
        ErrorMessageUser[203],
        ErrorCodeUser.PASSWORD_IS_NOT_CORRECT,
      );
    }
    const payload = {
      id: user.id,
      email: user.email,
      role: user.role,
    };
    await this.feeShippingService.updateOrderStatusById(user.id);
    return await this.generateToken(payload);
  }

  private async generateToken(payload: {
    id: number;
    email: string;
    role: string;
  }) {
    try {
      const accessToken = await this.jwtService.signAsync(payload, {
        secret: this.configService.get<string>('ACCESS_TOKEN_KEY'),
        expiresIn: this.configService.get<string>('EXPIRESIN_ACCESS_TOKEN'),
      });
      const refreshToken = await this.jwtService.signAsync(payload, {
        secret: this.configService.get<string>('REFRESH_TOKEN_KEY'),
        expiresIn: this.configService.get<string>('EXPIRESIN_REFRESH_TOKEN'),
      });
      const token = await this.tokenRepository.create({
        user_id: payload.id,
        token: refreshToken,
      });
      await this.tokenRepository.save(token);
      return {
        accessToken,
        refreshToken,
      };
    } catch (error) {
      throw new HttpException(
        ErrorMessageAuth[301],
        ErrorCodeAuth.ERROR_GENERATE_TOKEN,
      );
    }
  }

  async refresh(refreshToken: string): Promise<any> {
    try {
      const data = await this.jwtService.verify(refreshToken, {
        secret: this.configService.get<string>('REFRESH_TOKEN_KEY'),
      });

      const user = await this.getUserById(data.id);
      const payload = {
        id: user.id,
        email: user.email,
        role: user.role,
      };

      return await this.generateToken(payload);
    } catch (error) {
      throw new HttpException(
        ErrorMessageAuth[302] + error,
        ErrorCodeAuth.INVALID_TOKEN,
      );
    }
  }

  async profile(data: any): Promise<any> {
    try {
      const user = await this.userRepository
        .createQueryBuilder('user')
        .leftJoinAndSelect(
          'user.addresses',
          'address',
          'address.is_active = :isActive',
          { isActive: 1 },
        )
        .where('user.id = :id', { id: data.id })
        .getOne();

      return {
        id: user.id,
        email: user.email,
        image: user.image,
        role: user.role,
        address_id: user.addresses[0]?.id || null,
        province: user.addresses[0]?.province || null,
        district: user.addresses[0]?.district || null,
        ward: user.addresses[0]?.ward || null,
        detail_address: user.addresses[0]?.detail_address || null,
        phone_number: user.addresses[0]?.phone_number || null,
        full_name: user.addresses[0]?.fullname || null,
      };
    } catch (error) {
      throw new HttpException(
        ErrorMessageAuth[302] + error,
        ErrorCodeAuth.INVALID_TOKEN,
      );
    }
  }

  private async getOneUserOption(user: User): Promise<any> {
    return {
      id: user.id,
      email: user.email,
      image: user.image || null,
    };
  }
}
