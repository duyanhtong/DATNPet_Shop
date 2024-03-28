import { HttpException, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  ErrorCodeImage,
  ErrorMessageImage,
} from './constants/error-code-image.constant';
import { ManagedUpload } from 'aws-sdk/clients/s3';
import { S3 } from 'aws-sdk';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Image } from './entities/image.entity';

type S3UploadResult = ManagedUpload.SendData;

@Injectable()
export class ImageService {
  private readonly region;
  private readonly accessKeyId;
  private readonly secretAccessKey;
  private readonly publicBucketName;
  constructor(
    @InjectRepository(Image)
    private readonly imageRepository: Repository<Image>,

    private readonly configService: ConfigService,
  ) {
    this.region = this.configService.get('AWS_REGION');
    this.accessKeyId = this.configService.get('AWS_ACCESS_KEY_ID');
    this.secretAccessKey = this.configService.get('AWS_SECRET_ACCESS_KEY');
    this.publicBucketName = this.configService.get('AWS_PUBLIC_BUCKET_NAME');
  }

  private getS3() {
    return new S3({
      region: this.region,
      accessKeyId: this.accessKeyId,
      secretAccessKey: this.secretAccessKey,
    });
  }

  private slug(str) {
    str = str.replace(/^\s+|\s+$/g, ''); // trim
    str = str.toLowerCase();

    // remove accents, swap ñ for n, etc
    const from =
      'ÁÄÂÀÃÅČÇĆĎÉĚËÈÊẼĔȆĞÍÌÎÏİŇÑÓÖÒÔÕØŘŔŠŞŤÚŮÜÙÛÝŸŽáäâàãåčçćďéěëèêẽĕȇğíìîïıňñóöòôõøðřŕšşťúůüùûýÿžþÞĐđßÆa·/_,:;';
    const to =
      'AAAAAACCCDEEEEEEEEGIIIIINNOOOOOORRSSTUUUUUYYZaaaaaacccdeeeeeeeegiiiiinnooooooorrsstuuuuuyyzbBDdBAa------';
    for (let i = 0, l = from.length; i < l; i++) {
      str = str.replace(new RegExp(from.charAt(i), 'g'), to.charAt(i));
    }

    str = str
      .replace(/[^a-z0-9 -]/g, '') // remove invalid chars
      .replace(/\s+/g, '-') // collapse whitespace and replace by -
      .replace(/-+/g, '-'); // collapse dashes

    return str;
  }

  private async validateImages(file: Express.Multer.File): Promise<void> {
    const allowedMimeTypes = ['image/png', 'image/jpg', 'image/jpeg'];
    const maxFileSize = 5 * 1024 * 1024;
    if (file.size > maxFileSize) {
      throw new HttpException(
        ErrorMessageImage[501],
        ErrorCodeImage.FILE_SIZE_EXCEED,
      );
    }

    if (!allowedMimeTypes.includes(file.mimetype)) {
      throw new HttpException(
        ErrorMessageImage[502],
        ErrorCodeImage.INVALID_IMAGE_FILE,
      );
    }
  }

  private async uploadS3(
    file_buffer,
    key,
    content_type,
  ): Promise<S3UploadResult> {
    const s3 = this.getS3();
    const params = {
      Bucket: this.publicBucketName,
      Key: key,
      Body: file_buffer,
      ContentType: content_type,
      ACL: 'public-read',
    };
    return new Promise((resolve, reject) => {
      s3.upload(params, (err, data) => {
        if (err) {
          reject(err.message);
        }
        resolve(data);
      });
    });
  }

  async upload(file: Express.Multer.File): Promise<string> {
    try {
      await this.validateImages(file);
      if (!file || !file.originalname) {
        throw new HttpException(
          ErrorMessageImage[502],
          ErrorCodeImage.INVALID_IMAGE_FILE,
        );
      }
      const arr_name = file.originalname.split('.');
      const extension = arr_name.pop();
      const name = arr_name.join('.');
      const key = Date.now() + this.slug(name) + '.' + extension;
      const data = await this.uploadS3(file.buffer, key, file.mimetype);

      if (typeof data === 'object' && data.hasOwnProperty('Location')) {
        return data.Location;
      } else {
        throw new HttpException(
          ErrorMessageImage[503],
          ErrorCodeImage.S3_UPLOAD_ERROR,
        );
      }
    } catch (error) {
      throw new HttpException(
        ErrorMessageImage[503],
        ErrorCodeImage.S3_UPLOAD_ERROR,
      );
    }
  }

  async createImageId(file: Express.Multer.File): Promise<number> {
    const imgPath = await this.upload(file);
    const image = await this.imageRepository.create({
      path: imgPath,
    });
    await this.imageRepository.save(image);
    return image.id;
  }
}
