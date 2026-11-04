import { createHash, randomBytes } from 'node:crypto';
import { Prisma, type PrismaClient, type User } from '@prisma/client';
import bcrypt from 'bcrypt';
import jwt, { type JwtPayload, type SignOptions } from 'jsonwebtoken';
import type { z } from 'zod';
import type { Config } from '../../config.js';
import { AppError } from '../../lib/app-error.js';
import { DEFAULT_CATEGORIES } from '../../lib/default-categories.js';
import { toUserResponse } from '../me/me.service.js';
import type { loginBody, registerBody } from './auth.schemas.js';

const BCRYPT_COST = 12;

// Email yang tidak terdaftar tetap menjalankan bcrypt, supaya waktu respons tidak membocorkannya.
const dummyHash = bcrypt.hash('direkapin', BCRYPT_COST);

function hashToken(token: string) {
  return createHash('sha256').update(token).digest('hex');
}

function inviteError() {
  return new AppError('INVITE_INVALID', 422, 'Kode undangan tidak valid');
}

function validInviteWhere(code: string, now: Date) {
  return {
    code,
    usedById: null,
    OR: [{ expiresAt: null }, { expiresAt: { gt: now } }],
  };
}

async function issueTokens(tx: Prisma.TransactionClient, config: Config, user: User) {
  const accessToken = jwt.sign({}, config.JWT_SECRET, {
    subject: user.id,
    algorithm: 'HS256',
    expiresIn: config.ACCESS_TOKEN_TTL as SignOptions['expiresIn'],
  });
  const { exp, iat } = jwt.decode(accessToken) as JwtPayload;

  const refreshToken = randomBytes(32).toString('base64url');
  // shortcut: token lama tidak pernah dibersihkan, tambah job pembersihan jika tabelnya membesar.
  await tx.refreshToken.create({
    data: {
      userId: user.id,
      tokenHash: hashToken(refreshToken),
      expiresAt: new Date(Date.now() + config.REFRESH_TOKEN_TTL_DAYS * 86_400_000),
    },
  });

  return {
    accessToken,
    refreshToken,
    expiresIn: exp! - iat!,
    user: toUserResponse(user),
  };
}

export async function register(
  prisma: PrismaClient,
  config: Config,
  input: z.infer<typeof registerBody>,
) {
  // Kode dicek sebelum email, supaya orang tanpa kode tidak bisa menebak email yang terdaftar.
  const invite = await prisma.inviteCode.findFirst({
    where: validInviteWhere(input.inviteCode, new Date()),
  });
  if (!invite) throw inviteError();

  const passwordHash = await bcrypt.hash(input.password, BCRYPT_COST);

  try {
    return await prisma.$transaction(async (tx) => {
      const user = await tx.user.create({
        data: { name: input.name, email: input.email, passwordHash },
      });

      const now = new Date();
      const claimed = await tx.inviteCode.updateMany({
        where: validInviteWhere(input.inviteCode, now),
        data: { usedById: user.id, usedAt: now },
      });
      if (claimed.count !== 1) throw inviteError();

      await tx.wallet.create({
        data: {
          userId: user.id,
          name: 'Cash',
          type: 'CASH',
          icon: 'account_balance_wallet_rounded',
          color: '#14B8A6',
        },
      });
      await tx.category.createMany({
        data: DEFAULT_CATEGORIES.map((category, sortOrder) => ({
          ...category,
          userId: user.id,
          isDefault: true,
          sortOrder,
        })),
      });

      return issueTokens(tx, config, user);
    });
  } catch (error) {
    if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002') {
      throw new AppError('EMAIL_TAKEN', 409, 'Email sudah dipakai');
    }
    throw error;
  }
}

export async function login(
  prisma: PrismaClient,
  config: Config,
  input: z.infer<typeof loginBody>,
) {
  const user = await prisma.user.findUnique({ where: { email: input.email } });
  const matches = await bcrypt.compare(input.password, user?.passwordHash ?? (await dummyHash));
  if (!user || !matches) {
    throw new AppError('INVALID_CREDENTIALS', 401, 'Email atau password salah');
  }
  return issueTokens(prisma, config, user);
}

export async function refresh(prisma: PrismaClient, config: Config, refreshToken: string) {
  const tokenHash = hashToken(refreshToken);
  return prisma.$transaction(async (tx) => {
    const now = new Date();
    // updateMany atomik: dua refresh bersamaan dengan token yang sama, hanya satu yang lolos.
    const revoked = await tx.refreshToken.updateMany({
      where: { tokenHash, revokedAt: null, expiresAt: { gt: now } },
      data: { revokedAt: now },
    });
    if (revoked.count !== 1) {
      throw new AppError('REFRESH_INVALID', 401, 'Sesi berakhir. Silakan masuk lagi.');
    }
    const { user } = await tx.refreshToken.findUniqueOrThrow({
      where: { tokenHash },
      include: { user: true },
    });
    return issueTokens(tx, config, user);
  });
}

export async function logout(prisma: PrismaClient, refreshToken: string) {
  await prisma.refreshToken.updateMany({
    where: { tokenHash: hashToken(refreshToken), revokedAt: null },
    data: { revokedAt: new Date() },
  });
}
