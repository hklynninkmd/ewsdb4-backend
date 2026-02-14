import jwt from 'jsonwebtoken';
import config from '@/config';
import { JWTPayload } from '@/modules/auth/auth.types';
import {Try} from '@/shared/utils/Try';

export const generateToken = (payload: JWTPayload): string => {
  return jwt.sign(payload, config.jwt.secret, {
    expiresIn: config.jwt.expiresIn,
  } as jwt.SignOptions);
};

export const verifyToken = async (token: string): Promise<JWTPayload> => {
  return Try.execute(() => {
    return jwt.verify(token, config.jwt.secret) as JWTPayload;
  }).orElseThrow('Invalid or expired token', new Error('Invalid or expired token'));
};
