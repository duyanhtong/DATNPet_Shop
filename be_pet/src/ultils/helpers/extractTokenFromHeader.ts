export function extractTokenFromHeader(req): string | undefined {
  let type, token;
  if (req.headers.authorization) {
    [type, token] = req.headers.authorization.split(' ');
  }

  return type === 'Bearer' ? token : undefined;
}
