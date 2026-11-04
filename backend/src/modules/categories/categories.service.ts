import type { Category, PrismaClient, TxType } from '@prisma/client';
import type { z } from 'zod';
import { AppError } from '../../lib/app-error.js';
import { isUniqueViolation } from '../../lib/schemas.js';
import type { createCategoryBody, updateCategoryBody } from './categories.schemas.js';

function nameTaken() {
  return new AppError('NAME_TAKEN', 409, 'Nama sudah dipakai');
}

async function findOwned(prisma: PrismaClient, userId: string, id: string) {
  const category = await prisma.category.findFirst({ where: { id, userId } });
  if (!category) throw new AppError('NOT_FOUND', 404, 'Data tidak ditemukan');
  return category;
}

function toResponse(category: Category) {
  return {
    id: category.id,
    name: category.name,
    type: category.type,
    icon: category.icon,
    color: category.color,
    isDefault: category.isDefault,
    isHidden: category.isHidden,
    sortOrder: category.sortOrder,
  };
}

export async function listCategories(
  prisma: PrismaClient,
  userId: string,
  filter: { type?: TxType; includeHidden: boolean },
) {
  const categories = await prisma.category.findMany({
    where: {
      userId,
      ...(filter.type && { type: filter.type }),
      ...(filter.includeHidden ? {} : { isHidden: false }),
    },
    orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
  });
  return { items: categories.map(toResponse) };
}

export async function createCategory(
  prisma: PrismaClient,
  userId: string,
  input: z.infer<typeof createCategoryBody>,
) {
  try {
    const sortOrder = await prisma.category.count({ where: { userId } });
    return toResponse(await prisma.category.create({ data: { ...input, userId, sortOrder } }));
  } catch (error) {
    if (isUniqueViolation(error)) throw nameTaken();
    throw error;
  }
}

export async function updateCategory(
  prisma: PrismaClient,
  userId: string,
  id: string,
  input: z.infer<typeof updateCategoryBody>,
) {
  const existing = await findOwned(prisma, userId, id);
  if (existing.isDefault && input.name !== undefined && input.name !== existing.name) {
    throw new AppError('CATEGORY_DEFAULT', 409, 'Nama kategori bawaan tidak bisa diubah');
  }
  try {
    return toResponse(await prisma.category.update({ where: { id }, data: input }));
  } catch (error) {
    if (isUniqueViolation(error)) throw nameTaken();
    throw error;
  }
}

export async function deleteCategory(prisma: PrismaClient, userId: string, id: string) {
  const existing = await findOwned(prisma, userId, id);
  if (existing.isDefault) {
    throw new AppError('CATEGORY_DEFAULT', 409, 'Kategori bawaan tidak bisa dihapus');
  }
  await prisma.$transaction(async (tx) => {
    // "Lainnya" bawaan selalu ada: tidak bisa dihapus dan namanya tidak bisa diganti.
    const fallback = await tx.category.findFirstOrThrow({
      where: { userId, type: existing.type, isDefault: true, name: 'Lainnya' },
    });
    await tx.transaction.updateMany({
      where: { userId, categoryId: id },
      data: { categoryId: fallback.id },
    });
    await tx.category.delete({ where: { id } });
  });
}

/** Kategori di body harus milik user dan tipenya cocok (D-27). */
export async function assertCategory(
  prisma: PrismaClient,
  userId: string,
  id: string,
  type: TxType,
) {
  const category = await prisma.category.findFirst({ where: { id, userId, type } });
  if (!category) {
    throw new AppError('VALIDATION_ERROR', 400, 'Data belum valid', {
      categoryId: 'Pilih kategori',
    });
  }
}
