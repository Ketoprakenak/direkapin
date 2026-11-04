import { PrismaClient } from '@prisma/client';
import { afterAll, beforeEach, describe, expect, it } from 'vitest';
import { seedInviteCode } from '../prisma/seed.js';
import { resetDb } from './helpers.js';

const prisma = new PrismaClient();

beforeEach(() => resetDb(prisma));
afterAll(() => prisma.$disconnect());

async function createOwners() {
  const user = await prisma.user.create({
    data: { name: 'Uji', email: 'uji@example.test', passwordHash: 'x' },
  });
  const userId = user.id;
  const wallet = await prisma.wallet.create({
    data: { userId, name: 'Cash', type: 'CASH', icon: 'a', color: '#14B8A6' },
  });
  const category = await prisma.category.create({
    data: { userId, name: 'Makan', type: 'EXPENSE', icon: 'a', color: '#F97316' },
  });
  const transaction = await prisma.transaction.create({
    data: {
      userId,
      walletId: wallet.id,
      categoryId: category.id,
      type: 'EXPENSE',
      amount: 1000n,
      occurredAt: new Date(),
    },
  });
  const activity = await prisma.activity.create({
    data: { userId, title: 'Kuliah', date: new Date('2026-11-04T00:00:00Z') },
  });
  return { userId, transactionId: transaction.id, activityId: activity.id };
}

const photo = {
  filePath: 'a.jpg',
  thumbPath: 't.jpg',
  mimeType: 'image/jpeg',
  sizeBytes: 1,
  width: 1,
  height: 1,
};

describe('CHECK constraint attachment', () => {
  it('menerima tepat satu pemilik', async () => {
    const { userId, activityId } = await createOwners();
    await expect(
      prisma.attachment.create({ data: { ...photo, userId, activityId } }),
    ).resolves.toBeTruthy();
  });

  it('menolak tanpa pemilik', async () => {
    const { userId } = await createOwners();
    await expect(prisma.attachment.create({ data: { ...photo, userId } })).rejects.toThrow();
  });

  it('menolak dua pemilik', async () => {
    const { userId, activityId, transactionId } = await createOwners();
    await expect(
      prisma.attachment.create({ data: { ...photo, userId, activityId, transactionId } }),
    ).rejects.toThrow();
  });
});

describe('seed kode undangan', () => {
  it('membuat satu kode acak, lalu tidak membuat lagi', async () => {
    const first = await seedInviteCode(prisma);
    expect(first).toMatch(/^[0-9A-F]{16}$/);
    expect(await seedInviteCode(prisma)).toBeNull();
    expect(await prisma.inviteCode.count()).toBe(1);
  });
});
