export type ErrorCode =
  | 'VALIDATION_ERROR'
  | 'UNAUTHORIZED'
  | 'INVALID_CREDENTIALS'
  | 'REFRESH_INVALID'
  | 'NOT_FOUND'
  | 'EMAIL_TAKEN'
  | 'NAME_TAKEN'
  | 'INVITE_INVALID'
  | 'WALLET_IN_USE'
  | 'CATEGORY_DEFAULT'
  | 'FILE_TOO_LARGE'
  | 'UNSUPPORTED_MEDIA'
  | 'PHOTO_LIMIT_REACHED'
  | 'ARCHIVED'
  | 'ARCHIVE_EXPIRED'
  | 'RATE_LIMITED'
  | 'INTERNAL_ERROR';

export class AppError extends Error {
  constructor(
    readonly code: ErrorCode,
    readonly httpStatus: number,
    message: string,
    readonly details?: Record<string, string>,
  ) {
    super(message);
  }
}
