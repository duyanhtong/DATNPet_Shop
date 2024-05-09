import { UsePipes } from '@nestjs/common';
import { CustomValidationPipe } from '../validates/validation.pipe';


export function ValidateDto() {
  return UsePipes(new CustomValidationPipe());
}
