import { Process, Processor } from '@nestjs/bull';
import { Job } from 'bull';
import { MailService } from 'src/mail/mail.service';

@Processor('SEND_MAIL_QUEUE')
export class EmailConsumer {
  constructor(private readonly mailService: MailService) {}
  @Process('confirm_order')
  async confirmOrder(job: Job<unknown>) {
    console.log('Received job:', job.id, job.data);
    // try {
    //   await this.mailService.mailConfirmOrder(result);
    // } catch (error) {
    //   console.error('Error sending confirmation email:', error);
    // }
  }
}
