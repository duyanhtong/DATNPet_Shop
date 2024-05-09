import { MailerService } from '@nestjs-modules/mailer';
import { HttpException, Injectable } from '@nestjs/common';
import { SendMailDto } from './dtos/send_mail.dto';
import {
  ErrorCodeMail,
  ErrorMessageMail,
} from './constants/error-code-mail.constant';
import { MailConfirmOrderDto } from './dtos/mail_confirm_order.dto';

@Injectable()
export class MailService {
  constructor(private readonly mailerService: MailerService) {}

  // async send(data: SendMailDto): Promise<any> {
  //   try {
  //     await this.mailerService.sendMail({
  //       to: data.to,
  //       subject: data.subject,
  //       template: data.template,
  //       context: {
  //         name: data.name,
  //       },
  //     });
  //   } catch (error) {
  //     console.log(error);
  //     throw new HttpException(
  //       ErrorMessageMail[1301],
  //       ErrorCodeMail.ERROR_SEND_MAIL,
  //     );
  //   }
  // }

  async mailConfirmOrder(data: any): Promise<any> {
    try {
      await this.mailerService.sendMail({
        to: data.email,
        subject: 'Xác nhận đơn hàng #' + data.id,
        template: './confirmOrder', // Đảm bảo đường dẫn đến template đúng
        context: {
          // Tất cả các trường từ MailConfirmOrderDto được truyền vào context
          id: data.id,
          full_name: data.full_name,
          phone_number: data.phone_number,
          email: data.email,
          note: data.note,
          status: data.status,
          payment_method: data.payment_method,
          total_money: data.total_money,
          fee_shipping: data.fee_shipping,
          province: data.province,
          district: data.district,
          ward: data.ward,
          detail_address: data.detail_address,
          expected_shipping_date: data.expected_shipping_date,
          actual_shipping_date: data.actual_shipping_date,
          order_created_date: data.order_created_date,
          cartItems: data.cartItems, // Đây là phần quan trọng để handle mảng cartItems trong template
        },
      });
    } catch (error) {
      console.log(error);
      throw new HttpException(
        ErrorMessageMail[1301],
        ErrorCodeMail.ERROR_SEND_MAIL,
      );
    }
  }
}
