import type { Prisma, PrismaClient } from '@prisma/client';
import type { z } from 'zod';
import { AppError } from '../../lib/app-error.js';
import { toDbDate } from '../../lib/dates.js';
import { formatRupiah, toBigInt, toNumber } from '../../lib/money.js';
import { isUniqueViolation } from '../../lib/schemas.js';
import { assertCategory } from '../categories/categories.service.js';
import { assertActiveWallet } from '../wallets/wallets.service.js';
import type {
  createReceivableBody,
  payBody,
  updateDebtorBody,
  updateReceivableBody,
} from './receivables.schemas.js';

/** Kategori bawaan pembayaran piutang, dibuat saat pertama dipakai (pola D-56). */
const PAYMENT_CATEGORY = {
  name: 'Piutang dibayar',
  type: 'INCOME',
  icon: 'handshake_rounded',
  color: '#64748B',
} as const;

/** Kategori bawaan pemasukan utang pinjam tunai (D-78). */
const LOAN_CATEGORY = { ...PAYMENT_CATEGORY, name: 'Pinjaman diterima' } as const;

type Direction = 'RECEIVABLE' | 'PAYABLE';

const walletRefSelect = { select: { id: true, name: true, icon: true, color: true } } as const;

async function upsertDefaultCategory(
  tx: Prisma.TransactionClient,
  userId: string,
  category: typeof PAYMENT_CATEGORY | typeof LOAN_CATEGORY,
) {
  return tx.category.upsert({
    where: { userId_name_type: { userId, name: category.name, type: category.type } },
    update: {},
    create: { ...category, userId, sortOrder: await tx.category.count({ where: { userId } }) },
  });
}

const receivableInclude = {
  loanTransaction: { select: { id: true, amount: true, wallet: walletRefSelect } },
  sourceTransaction: { select: { id: true, amount: true, category: { select: { name: true } } } },
  debtors: {
    orderBy: { sortOrder: 'asc' },
    include: {
      payments: {
        include: {
          transaction: {
            select: {
              amount: true,
              occurredAt: true,
              wallet: walletRefSelect,
            },
          },
        },
      },
    },
  },
} satisfies Prisma.ReceivableInclude;
type ReceivableRow = Prisma.ReceivableGetPayload<{ include: typeof receivableInclude }>;
type DebtorRow = ReceivableRow['debtors'][number];

const notFound = () => new AppError('NOT_FOUND', 404, 'Data tidak ditemukan');
const invalid = (field: string, message: string) =>
  new AppError('VALIDATION_ERROR', 400, 'Data belum valid', { [field]: message });

const paidOf = (debtor: Pick<DebtorRow, 'payments'>) =>
  debtor.payments.reduce((sum, p) => sum + p.transaction.amount, 0n);

export function toReceivableResponse(row: ReceivableRow) {
  const debtors = row.debtors.map((debtor) => {
    const paid = paidOf(debtor);
    return {
      id: debtor.id,
      name: debtor.name,
      amount: toNumber(debtor.amount),
      paid: toNumber(paid),
      remaining: toNumber(debtor.amount - paid),
      payments: debtor.payments
        .map((p) => ({
          transactionId: p.transactionId,
          amount: toNumber(p.transaction.amount),
          occurredAt: p.transaction.occurredAt.toISOString(),
          wallet: p.transaction.wallet,
        }))
        .sort((a, b) => b.occurredAt.localeCompare(a.occurredAt)),
    };
  });
  return {
    id: row.id,
    direction: row.direction,
    title: row.title,
    date: row.date.toISOString().slice(0, 10),
    note: row.note,
    total: debtors.reduce((sum, d) => sum + d.amount, 0),
    remaining: debtors.reduce((sum, d) => sum + d.remaining, 0),
    loan: row.loanTransaction && {
      transactionId: row.loanTransaction.id,
      amount: toNumber(row.loanTransaction.amount),
      wallet: row.loanTransaction.wallet,
    },
    source: row.sourceTransaction && {
      transactionId: row.sourceTransaction.id,
      amount: toNumber(row.sourceTransaction.amount),
      categoryName: row.sourceTransaction.category.name,
    },
    debtors,
  };
}

async function findOwned(prisma: PrismaClient, userId: string, id: string) {
  const row = await prisma.receivable.findFirst({
    where: { id, userId },
    include: receivableInclude,
  });
  if (!row) throw notFound();
  return row;
}

export async function findOwnedDebtor(prisma: PrismaClient, userId: string, debtorId: string) {
  const debtor = await prisma.receivableDebtor.findFirst({
    where: { id: debtorId, receivable: { userId } },
    include: { receivable: { select: { title: true, direction: true } } },
  });
  if (!debtor) throw notFound();
  return debtor;
}

export async function listReceivables(
  prisma: PrismaClient,
  userId: string,
  status: 'open' | 'all',
  direction: Direction,
) {
  const rows = await prisma.receivable.findMany({
    where: { userId, direction },
    include: receivableInclude,
    orderBy: [{ date: 'desc' }, { createdAt: 'desc' }],
  });
  // shortcut: sisa dihitung di JS dari semua talangan; cukup untuk maks. 4 user, pindah ke SQL jika ribuan.
  const all = rows.map(toReceivableResponse);
  return {
    items: status === 'all' ? all : all.filter((r) => r.remaining > 0),
    totalRemaining: all.reduce((sum, r) => sum + r.remaining, 0),
  };
}

/**
 * Sisa semua piutang/utang untuk dashboard (D-77, D-78): Σ nominal orang − Σ pembayaran.
 * [frontedOnly]: hanya utang ditalangin (tanpa transaksi pinjaman), D-81.
 */
export async function receivableRemaining(
  prisma: PrismaClient,
  userId: string,
  direction: Direction,
  frontedOnly = false,
) {
  const receivable = { direction, ...(frontedOnly && { loanTransactionId: null }) };
  const [owed, paid] = await Promise.all([
    prisma.receivableDebtor.aggregate({
      where: { receivable: { userId, ...receivable } },
      _sum: { amount: true },
    }),
    prisma.transaction.aggregate({
      where: { userId, receivablePayment: { debtor: { receivable } } },
      _sum: { amount: true },
    }),
  ]);
  return toNumber((owed._sum.amount ?? 0n) - (paid._sum.amount ?? 0n));
}

export async function createReceivable(
  prisma: PrismaClient,
  userId: string,
  input: z.infer<typeof createReceivableBody>,
) {
  const { loanWalletId, clientId } = input;
  if (loanWalletId) await assertActiveWallet(prisma, userId, loanWalletId, 'loanWalletId');

  // Kiriman ulang dengan clientId sama: kembalikan catatan pertama, jangan buat pinjaman lagi (D-58).
  const replay = async () => {
    const existing =
      clientId &&
      (await prisma.receivable.findFirst({
        where: { userId, clientId },
        include: receivableInclude,
      }));
    return existing ? toReceivableResponse(existing) : null;
  };
  const previous = await replay();
  if (previous) return previous;

  // Bagi ke teman (FIN-21): sumber harus pengeluaran sendiri, bagian teman <= nominalnya.
  const { sourceTransactionId } = input;
  const alreadySplit = () => invalid('sourceTransactionId', 'Pengeluaran ini sudah dibagi');
  if (sourceTransactionId) {
    const source = await prisma.transaction.findFirst({
      // Biaya admin transfer dan cicilan utang bukan pengeluaran yang bisa dibagi.
      where: {
        id: sourceTransactionId,
        userId,
        type: 'EXPENSE',
        feeOf: { is: null },
        receivablePayment: { is: null },
      },
      select: { amount: true, receivableSource: { select: { id: true } } },
    });
    if (!source) throw invalid('sourceTransactionId', 'Pilih pengeluaran');
    if (source.receivableSource) throw alreadySplit();
    const shared = input.debtors.reduce((sum, d) => sum + toBigInt(d.amount), 0n);
    if (shared > source.amount) {
      throw invalid('debtors', `Melebihi nominal pengeluaran ${formatRupiah(source.amount)}`);
    }
  }

  const create = () =>
    prisma.$transaction(async (tx) => {
      // Pinjam tunai: uang masuk ke dompet sebagai pemasukan "Pinjaman diterima" (D-78).
      let loanTransactionId: string | undefined;
      const [first] = input.debtors;
      if (loanWalletId && first) {
        const category = await upsertDefaultCategory(tx, userId, LOAN_CATEGORY);
        const loan = await tx.transaction.create({
          data: {
            userId,
            walletId: loanWalletId,
            categoryId: category.id,
            type: 'INCOME',
            amount: toBigInt(first.amount),
            occurredAt: new Date(),
            note: `Pinjam ${first.name} · ${input.title}`.slice(0, 1000),
          },
        });
        loanTransactionId = loan.id;
      }
      return tx.receivable.create({
        data: {
          userId,
          direction: input.direction,
          loanTransactionId,
          clientId,
          sourceTransactionId,
          title: input.title,
          date: toDbDate(input.date),
          note: input.note,
          debtors: {
            create: input.debtors.map((d, index) => ({
              name: d.name,
              amount: toBigInt(d.amount),
              sortOrder: index,
            })),
          },
        },
        include: receivableInclude,
      });
    });
  try {
    return toReceivableResponse(await create());
  } catch (error) {
    if (!isUniqueViolation(error)) throw error;
    const winner = clientId ? await replay() : null;
    if (winner) return winner;
    // Dua bagi bersamaan untuk pengeluaran yang sama: yang kalah dapat 400, bukan 500.
    if (sourceTransactionId) throw alreadySplit();
    throw error;
  }
}

export async function updateReceivable(
  prisma: PrismaClient,
  userId: string,
  id: string,
  input: z.infer<typeof updateReceivableBody>,
) {
  await findOwned(prisma, userId, id);
  const row = await prisma.receivable.update({
    where: { id },
    data: { ...input, ...(input.date && { date: toDbDate(input.date) }) },
    include: receivableInclude,
  });
  return toReceivableResponse(row);
}

/** Pembayaran (transaksi pemasukan) tetap ada; hanya talangan dan tautannya yang hilang. */
export async function deleteReceivable(prisma: PrismaClient, userId: string, id: string) {
  await findOwned(prisma, userId, id);
  await prisma.receivable.delete({ where: { id } });
}

export async function updateDebtor(
  prisma: PrismaClient,
  userId: string,
  debtorId: string,
  input: z.infer<typeof updateDebtorBody>,
) {
  const debtor = await findOwnedDebtor(prisma, userId, debtorId);
  await prisma.$transaction(async (tx) => {
    await tx.$queryRaw`SELECT id FROM receivable_debtors WHERE id = ${debtorId}::uuid FOR UPDATE`;
    if (input.amount !== undefined) {
      const paid = await paidSum(tx, debtorId);
      if (toBigInt(input.amount) < paid) {
        throw invalid('amount', 'Nominal tidak boleh kurang dari yang sudah dibayar');
      }
    }
    await tx.receivableDebtor.update({
      where: { id: debtorId },
      data: {
        ...(input.name !== undefined && { name: input.name }),
        ...(input.amount !== undefined && { amount: toBigInt(input.amount) }),
      },
    });
  });
  return toReceivableResponse(await findOwned(prisma, userId, debtor.receivableId));
}

async function paidSum(tx: Prisma.TransactionClient, debtorId: string) {
  const { _sum } = await tx.transaction.aggregate({
    where: { receivablePayment: { debtorId } },
    _sum: { amount: true },
  });
  return _sum.amount ?? 0n;
}

/**
 * Cicilan piutang = pemasukan "Piutang dibayar" (D-77);
 * cicilan utang = pengeluaran berkategori pilihan (D-78).
 */
export async function payDebtor(
  prisma: PrismaClient,
  userId: string,
  debtorId: string,
  input: z.infer<typeof payBody>,
) {
  const debtor = await findOwnedDebtor(prisma, userId, debtorId);
  await assertActiveWallet(prisma, userId, input.walletId, 'walletId');
  const payable = debtor.receivable.direction === 'PAYABLE';
  const { categoryId } = input;
  if (payable) {
    if (!categoryId) throw invalid('categoryId', 'Pilih kategori');
    await assertCategory(prisma, userId, categoryId, 'EXPENSE');
  }
  const done = () => findOwned(prisma, userId, debtor.receivableId).then(toReceivableResponse);

  // Kiriman ulang dengan clientId sama: kembalikan hasil pertama (D-58).
  if (input.clientId) {
    const existing = await prisma.transaction.findFirst({
      where: { userId, clientId: input.clientId },
    });
    if (existing) return done();
  }

  try {
    await prisma.$transaction(async (tx) => {
      // Kunci baris orang supaya dua cicilan bersamaan tidak melewati sisa.
      await tx.$queryRaw`SELECT id FROM receivable_debtors WHERE id = ${debtorId}::uuid FOR UPDATE`;
      const remaining = debtor.amount - (await paidSum(tx, debtorId));
      if (toBigInt(input.amount) > remaining) {
        throw invalid('amount', `Melebihi sisa utang ${formatRupiah(remaining)}`);
      }
      const prefix = payable ? 'Bayar utang' : 'Bayar';
      const transaction = await tx.transaction.create({
        data: {
          userId,
          walletId: input.walletId,
          categoryId:
            payable && categoryId
              ? categoryId
              : (await upsertDefaultCategory(tx, userId, PAYMENT_CATEGORY)).id,
          type: payable ? 'EXPENSE' : 'INCOME',
          amount: toBigInt(input.amount),
          occurredAt: input.occurredAt,
          note: `${prefix} ${debtor.name} · ${debtor.receivable.title}`.slice(0, 1000),
          clientId: input.clientId,
        },
      });
      await tx.receivablePayment.create({ data: { debtorId, transactionId: transaction.id } });
    });
  } catch (error) {
    if (!(input.clientId && isUniqueViolation(error))) throw error;
  }
  return done();
}
