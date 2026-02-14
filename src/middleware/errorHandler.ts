import { Request, Response, NextFunction } from 'express';
import logger from '@/shared/logger';
import { AppError, ValidationError } from '@/shared/errors/AppError';

// Re-export error classes for backward compatibility
export { AppError, BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, ConflictError, ValidationError, InternalServerError, ServiceUnavailableError } from '@/shared/errors/AppError';

export const errorHandler = (
  err: Error | AppError,
  req: Request,
  res: Response,
  _next: NextFunction
) => {
  if (err instanceof AppError) {
    logger.error(`${err.statusCode} - ${err.message} - ${req.originalUrl} - ${req.method}`);

    const errorResponse: any = {
      success: false,
      statusCode: err.statusCode,
      message: err.message,
      timestamp: new Date().toISOString(),
      path: req.originalUrl,
    };

    // Include validation errors if present
    if (err instanceof ValidationError && err.errors) {
      errorResponse.errors = err.errors;
    }

    // Include stack trace in development
    if (process.env.NODE_ENV === 'development') {
      errorResponse.stack = err.stack;
    }

    return res.status(err.statusCode).json(errorResponse);
  }

  // Handle unknown errors
  logger.error(`500 - ${err.message} - ${req.originalUrl} - ${req.method} - ${err.stack}`);

  return res.status(500).json({
    success: false,
    statusCode: 500,
    message: 'Internal server error',
    timestamp: new Date().toISOString(),
    path: req.originalUrl,
    ...(process.env.NODE_ENV === 'development' && { error: err.message, stack: err.stack }),
  });
};

export const notFoundHandler = (req: Request, res: Response) => {
  res.status(404).json({
    success: false,
    message: `Route ${req.originalUrl} not found`,
  });
};
