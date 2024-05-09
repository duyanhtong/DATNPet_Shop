import {
  Body,
  Controller,
  Get,
  HttpStatus,
  Post,
  Req,
  Res,
} from '@nestjs/common';
import { VnpayService } from './vnpay.service';
import { Public } from 'src/auth/decorators/public.decorator';
import * as moment from 'moment'; // Sửa import moment thành * as moment
import * as crypto from 'crypto'; // Thêm import crypto
import * as querystring from 'qs';

import { Request, Response } from 'express';
@Controller('vnpay')
export class VnpayController {
  constructor(private readonly vnpayService: VnpayService) {}

  @Get()
  @Public()
  async getAllBank(): Promise<any> {
    return await this.vnpayService.getAllBank();
  }

  @Public()
  @Post('/create_payment_url')
  createPaymentUrl(@Req() req: Request, @Body() body, @Res() res: Response) {
    process.env.TZ = 'Asia/Ho_Chi_Minh';

    const date = new Date();
    const createDate = moment(date).format('YYYYMMDDHHmmss');
    const orderId = moment(date).format('DDHHmmss');
    const amount = body.amount;
    const bankCode = body.bankCode;
    let locale = body.language;
    if (!locale) {
      locale = 'vn';
    }

    const ipAddr = req.headers['x-forwarded-for'] || req.socket.remoteAddress;

    const tmnCode = 'PSSR9AZM';
    const secretKey = 'SMXVCXZNMSUDLJNZFXDCHTAOJONPAMXX';
    let vnpUrl = 'https://sandbox.vnpayment.vn/merchant_webapi/api/transaction';
    const returnUrl = 'https://www.youtube.com/';

    let vnp_Params: any = {
      vnp_Version: '2.1.0',
      vnp_Command: 'pay',
      vnp_TmnCode: tmnCode,
      vnp_Locale: locale,
      vnp_CurrCode: 'VND',
      vnp_TxnRef: orderId, // Sửa lại từ 'test1' thành orderId để mã giao dịch là duy nhất
      vnp_OrderInfo: 'Thanh toan cho ma GD:' + orderId,
      vnp_OrderType: 'other',
      vnp_Amount: amount * 100, // Đảm bảo amount được nhân với 100 vì VNPAY yêu cầu số tiền phải là đơn vị "đồng", không phải "xu"
      vnp_ReturnUrl: returnUrl,
      vnp_IpAddr: ipAddr,
      vnp_CreateDate: createDate,
    };
    if (bankCode) {
      vnp_Params['vnp_BankCode'] = bankCode;
    }

    // Assuming sortObject is a custom function you've implemented
    vnp_Params = this.sortParams(vnp_Params);

    const signData = querystring.stringify(vnp_Params, { encode: false });
    const hmac = crypto.createHmac('sha512', secretKey);
    const signed = hmac.update(Buffer.from(signData, 'utf-8')).digest('hex');
    vnp_Params['vnp_SecureHash'] = signed;
    vnpUrl += '?' + querystring.stringify(vnp_Params, { encode: false });
    console.log(vnpUrl);
    // Sử dụng phương thức res.redirect() để chuyển hướng người dùng
    res.redirect(vnpUrl);
    // Không cần return vnpUrl nữa vì đã thực hiện chuyển hướng
  }

  sortParams(obj) {
    let sorted = {};
    let str = [];
    let key;
    for (key in obj) {
      if (obj.hasOwnProperty(key)) {
        str.push(encodeURIComponent(key));
      }
    }
    str.sort();
    for (key = 0; key < str.length; key++) {
      sorted[str[key]] = encodeURIComponent(obj[str[key]]).replace(/%20/g, '+');
    }
    return sorted;
  }
}
