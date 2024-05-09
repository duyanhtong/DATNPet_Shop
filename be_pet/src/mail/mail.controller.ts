import { Body, Controller, Post } from '@nestjs/common';
import { MailService } from './mail.service';
import { Public } from 'src/auth/decorators/public.decorator';
import { MailConfirmOrderDto } from './dtos/mail_confirm_order.dto';

@Controller('mail')
export class MailController {
  constructor(private readonly mailService: MailService) {}
  @Public()
  @Post()
  async SendMail(@Body() data: MailConfirmOrderDto): Promise<any> {
    return await this.mailService.mailConfirmOrder(data);
  }
}
