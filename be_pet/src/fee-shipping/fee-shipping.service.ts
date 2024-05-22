import { HttpException, HttpStatus, Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios, { AxiosRequestConfig } from 'axios';
import {
  ErrorCodeFeeShipping,
  ErrorMessageFeeShipping,
} from './constants/error-code-fee_shippingconstant';
import { removeDiacriticsAndSpaces } from 'src/ultils/helpers/removeDiacriticsAndSpaces';
import { CalculateFeeShippingDto } from './dtos/fee-shipping.calculate.dto';
import { CreateOrderGHNDTO } from './dtos/create-order_GHN.dto';
import { GHNResponseData } from './interfaces/order.GHN-response-data';
import { Order } from 'src/order/entities/order.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { Not, Repository } from 'typeorm';
import { Cron, CronExpression } from '@nestjs/schedule';
import {
  getStatusValueByKey,
  OrderStatusEnum,
} from 'src/order/constants/order.status.constant';

@Injectable()
export class FeeShippingService {
  private readonly api_key;
  private readonly url_api_province;
  private readonly url_api_district;
  private readonly url_api_ward;
  private readonly url_api_fee_shipping;
  private readonly shop_id;
  private readonly config: AxiosRequestConfig;
  private readonly service_type_id;
  private readonly url_api_create_order;
  private readonly url_api_cancel_order;
  private readonly url_api_get_detail_url;
  private readonly logger = new Logger(FeeShippingService.name);

  constructor(
    private readonly configService: ConfigService,
    @InjectRepository(Order)
    private readonly orderRepository: Repository<Order>,
  ) {
    this.api_key = this.configService.get('API_KEY_DEV');
    this.url_api_province = this.configService.get('URL_API_PROVINCE_DEV');
    this.url_api_district = this.configService.get('URL_API_DISTRICT_DEV');
    this.url_api_ward = this.configService.get('URL_API_WARD_DEV');
    this.url_api_fee_shipping = this.configService.get(
      'URL_API_FEE_SHIPPING_DEV',
    );
    this.shop_id = this.configService.get('SHOP_ID_DEV');
    this.service_type_id = 2;
    this.url_api_create_order = this.configService.get(
      'URL_API_CREATE_ORDER_DEV',
    );
    this.url_api_cancel_order = this.configService.get('ULR_API_CANCEL_ORDER');
    this.url_api_get_detail_url = this.configService.get(
      'URL_API_GET_DETAIL_ORDER',
    );
    this.config = {
      headers: {
        'Content-Type': 'application/json',
        token: this.api_key,
        ShopId: this.shop_id,
      },
    };
  }

  async getProvinceId(provinceName: string): Promise<number> {
    try {
      const res = await axios.get(this.url_api_province, this.config);
      const data = res.data.data;

      const foundProvince = data.find((province) =>
        province.NameExtension.some(async (name) =>
          name
            .toLowerCase()
            .includes(await removeDiacriticsAndSpaces(provinceName)),
        ),
      );

      if (foundProvince) {
        return foundProvince.ProvinceID;
      } else {
        throw new HttpException(
          ErrorMessageFeeShipping[1102],
          ErrorCodeFeeShipping.PROVINCE_ID_NOT_FOUND,
        );
      }
    } catch (e) {
      throw new HttpException(
        ErrorMessageFeeShipping[1101] + e,
        HttpStatus.BAD_REQUEST,
      );
    }
  }

  async getDistrictId(
    provinceName: string,
    districtName: string,
  ): Promise<number> {
    const provinceId = await this.getProvinceId(provinceName);

    const data = {
      province_id: provinceId,
    };
    try {
      const response = await axios.post(
        this.url_api_district,
        data,
        this.config,
      );
      const districts = response.data.data;
      const foundDistrict = districts.find((district) =>
        district.NameExtension.some(async (name) =>
          name
            .toLowerCase()
            .includes(await removeDiacriticsAndSpaces(districtName)),
        ),
      );
      if (foundDistrict) {
        return foundDistrict.DistrictID;
      } else {
        throw new HttpException(
          ErrorMessageFeeShipping[1104],
          ErrorCodeFeeShipping.DISTRICT_ID_NOT_FOUND,
        );
      }
    } catch (e) {
      throw new HttpException(
        ErrorMessageFeeShipping[1103],
        ErrorCodeFeeShipping.ERROR_GET_DISTRICT_DATA,
      );
    }
  }

  async getWardCode(
    provinceName: string,
    districtName: string,
    wardName: string,
  ): Promise<string> {
    const districtId = await this.getDistrictId(provinceName, districtName);
    const data = {
      district_id: districtId,
    };

    try {
      const response = await axios.post(this.url_api_ward, data, this.config);
      const wards = response.data.data;
      const foundWards = wards.find((district) =>
        district.NameExtension.some(async (name) =>
          name
            .toLowerCase()
            .includes(await removeDiacriticsAndSpaces(wardName)),
        ),
      );
      if (foundWards) {
        return foundWards.WardCode;
      } else {
        throw new HttpException(
          ErrorMessageFeeShipping[1106],
          ErrorCodeFeeShipping.WARD_ID_NOT_FOUND,
        );
      }
    } catch (error) {
      throw new HttpException(
        ErrorMessageFeeShipping[1105],
        ErrorCodeFeeShipping.ERROR_GET_WARD_DATA,
      );
    }
  }

  async calculateFeeShipping(data: CalculateFeeShippingDto): Promise<number> {
    const from_district_id = await this.getDistrictId(
      data.from_province_name,
      data.from_district_name,
    );
    const from_ward_code = await this.getWardCode(
      data.from_province_name,
      data.from_district_name,
      data.from_ward_name,
    );

    const to_district_id = await this.getDistrictId(
      data.to_province_name,
      data.to_district_name,
    );
    const to_ward_code = await this.getWardCode(
      data.to_province_name,
      data.to_district_name,
      data.to_ward_name,
    );

    const dataCalculateFee = {
      service_type_id: this.service_type_id,
      from_district_id: from_district_id,
      from_ward_code: from_ward_code,
      to_district_id: to_district_id,
      to_ward_code: to_ward_code,
      weight: data.weight,
      items: data.items,
    };

    try {
      const response = await axios.post(
        this.url_api_fee_shipping,
        dataCalculateFee,
        this.config,
      );
      return response.data.data.total;
    } catch (error) {
      throw new HttpException(
        ErrorMessageFeeShipping[1107],
        ErrorCodeFeeShipping.ERROR_CALCULATE_FEE_SHIPPING,
      );
    }
  }
  async createOrderGHN(data: CreateOrderGHNDTO): Promise<GHNResponseData> {
    const dataOrderGHN = {
      service_type_id: this.service_type_id,
      payment_type_id: 1,
      required_note: 'KHONGCHOXEMHANG',
      from_name: this.configService.get('SHOP_NAME'),
      from_phone: this.configService.get('SHOP_PHONE'),
      from_address: `${data.from_ward_name}, ${data.from_district_name}, ${data.to_province_name}`,
      from_ward_name: data.from_ward_name,
      from_district_name: data.from_district_name,
      from_province_name: data.from_province_name,
      to_name: data.name_user,
      to_phone: data.phone_user,
      to_address: data.address_detail_user,
      to_ward_name: data.to_district_name,
      to_district_name: data.to_district_name,
      to_province_name: data.to_province_name,
      cod_amount: data.feeShipping + data.totalMoney,
      note: data.note,
      weight: data.weight,
      insurance_value: data.totalMoney,
      items: data.items,
    };
    try {
      const response = await axios.post(
        this.url_api_create_order,
        dataOrderGHN,
        this.config,
      );
      return response.data.data;
    } catch (error) {
      throw new HttpException(
        ErrorMessageFeeShipping[1108] + error.response
          ? error.response.data
          : error.message,
        ErrorCodeFeeShipping.ERROR_CREATE_ORDER_GHN,
      );
    }
  }

  async updateOrderStatus(orders: Order[]) {
    try {
      const promises = orders.map(async (order) => {
        this.logger.debug('Update status order', order.id);
        if (order.order_code != null) {
          const dataStatus = {
            order_code: order.order_code,
          };

          const response = await axios.post(
            this.url_api_get_detail_url,
            dataStatus,
            this.config,
          );
          const status = getStatusValueByKey(response.data.data.status);
          if (status == OrderStatusEnum.delivered) {
          }
          order.status = status;
          await this.orderRepository.save(order);
        }
      });
      await Promise.all(promises);
    } catch (error) {
      this.logger.error(`Failed to update orders: ${error.message}`);
    }
  }

  async updateAllOrder(): Promise<void> {
    const orders = await this.orderRepository.find();
    await this.updateOrderStatus(orders);
  }

  @Cron(CronExpression.EVERY_2_HOURS)
  async handleCron() {
    this.logger.debug('----------Called every 2 Hours---------');
    await this.updateAllOrder();
  }

  async updateOrderStatusById(user_id: number): Promise<void> {
    this.logger.debug('Run Update order by User', user_id);
    const orders = await this.orderRepository.find({
      where: { user_id: user_id, status: Not(OrderStatusEnum.delivered) },
    });
    await this.updateOrderStatus(orders);
  }
}
