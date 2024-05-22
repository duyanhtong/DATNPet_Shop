import { HttpException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { User } from './entities/user.entity';
import { Repository } from 'typeorm';
import { ImageService } from 'src/image/image.service';
import {
  ErrorCodeUser,
  ErrorMessageUser,
} from './constants/error-code-user.constant';

@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User) private readonly userRepository: Repository<User>,
    private readonly imageService: ImageService,
  ) {}

  private async checkUserId(id: number): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id: id } });
    if (!user) {
      throw new HttpException(
        ErrorMessageUser[202],
        ErrorCodeUser.USER_NOT_FOUND,
      );
    }
    return user;
  }

  async upload(id: number, userImage: Express.Multer.File): Promise<any> {
    const user = await this.checkUserId(id);
    const path = await this.imageService.upload(userImage);
    user.image = path;
    await this.userRepository.save(user);
    
    return await this.getOneUserOption(user);
  }

  private async getOneUserOption(user: User): Promise<any> {
    return {
      id: user.id,
      email: user.email,
      image: user.image || null,
    };
  }
}
