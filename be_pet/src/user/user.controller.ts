import {
  Controller,
  Param,
  ParseIntPipe,
  Put,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { UserService } from './user.service';
import BaseController from 'src/ultils/base/response.base';
import { Roles } from 'src/auth/decorators/role.decorator';
import { FileInterceptor } from '@nestjs/platform-express';
import CommonError from 'src/ultils/base/error-code.base';

@Controller('user')
export class UserController extends BaseController {
  constructor(private readonly userService: UserService) {
    super();
  }

  @Put('upload/:id')
  @Roles('admin', 'user')
  @UseInterceptors(FileInterceptor('userImage'))
  async upload(
    @Param('id', ParseIntPipe) id: number,
    @UploadedFile()
    userImage: Express.Multer.File,
  ): Promise<any> {
    try {
      const result = await this.userService.upload(id, userImage);
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
