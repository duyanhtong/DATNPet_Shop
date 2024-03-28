import { applyDecorators, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

export function JwtAuthReq() {
  return applyDecorators(UseGuards(AuthGuard('jwt')));
}
