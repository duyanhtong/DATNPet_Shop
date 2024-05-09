import { Injectable } from '@nestjs/common';
import { VNPay } from 'vnpay';

@Injectable()
export class VnpayService {
  private vnpay;
  constructor() {
    this.vnpay = new VNPay({
      tmnCode: 'B2WFG8TV',
      secureSecret: 'KHHVQNLPXVGYDBZBTYTBTRBPOPDAZCKV',
      vnpayHost: 'https://sandbox.vnpayment.vn',
      testMode: true, // optional
      hashAlgorithm: 'SHA512', // optional
    });
  }

  async getAllBank(): Promise<any> {
    return await this.vnpay.getBankList();
  }

  // async createPaymentUrl(): Promise<any> {
  //   process.env.TZ = 'Asia/Ho_Chi_Minh';

  //   let date = new Date();
  //   let createDate = moment(date).format('YYYYMMDDHHmmss');

  //   let ipAddr =
  //     req.headers['x-forwarded-for'] ||
  //     req.connection.remoteAddress ||
  //     req.socket.remoteAddress ||
  //     req.connection.socket.remoteAddress;
  // }
}
