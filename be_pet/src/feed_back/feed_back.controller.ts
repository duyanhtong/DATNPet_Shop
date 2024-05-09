import {
  Body,
  Controller,
  Get,
  Logger,
  Param,
  ParseIntPipe,
  Post,
  Put,
  Query,
  Request,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { FeedBackService } from './feed_back.service';
import { Roles } from 'src/auth/decorators/role.decorator';
import { ValidateDto } from 'src/ultils/decorators/pipe-validate.decorator';
import { CreateFeedbackDto } from './dtos/create_feed-back.dto';
import BaseController from 'src/ultils/base/response.base';
import CommonError from 'src/ultils/base/error-code.base';
import { UpdateFeedbackDto } from './dtos/update_feed-back.dto';
import { FileInterceptor } from '@nestjs/platform-express';
import { Public } from 'src/auth/decorators/public.decorator';
import { FeedbackFilterType } from './interfaces/feedback.filter-type.interface';
import { JwtAuthReq } from 'src/auth/decorators/strategy.decorator';

@Controller('feed-back')
export class FeedBackController extends BaseController {
  constructor(private readonly feedBackService: FeedBackService) {
    super();
  }

  @Post()
  @Roles('admin', 'user')
  @ValidateDto()
  async create(@Body() data: CreateFeedbackDto): Promise<any> {
    try {
      const result = await this.feedBackService.create(data);
      if (result instanceof CommonError) {
        throw result;
      }
      return this.data(result);
    } catch (error) {
      if (error instanceof CommonError) return error;
      return this.fail(error);
    }
  }

  @Put(':id')
  @Roles('admin', 'user')
  @ValidateDto()
  @UseInterceptors(FileInterceptor('feedbackImage'))
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() body: UpdateFeedbackDto,
    @UploadedFile()
    feedbackImage?: Express.Multer.File,
  ): Promise<any> {
    console.log('run api update feeback ', id);
    console.log(body);
    try {
      const result = await this.feedBackService.update(id, body, feedbackImage);
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
  @Get()
  @JwtAuthReq()
  async getAll(
    @Request() req: any,
    @Query() filter: FeedbackFilterType,
  ): Promise<any> {
    try {
      const result = await this.feedBackService.getList({
        user: req.user,
        filter,
      });
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
  @Get('public')
  async getList(@Query() filter: FeedbackFilterType): Promise<any> {
    try {
      const result = await this.feedBackService.getList({
        user: null,
        filter,
      });
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
