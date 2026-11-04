import { randomBytes } from 'node:crypto';
import { pathToFileURL } from 'node:url';
import { PrismaClient } from '@prisma/client';

// Kategori bawaan tidak di-seed: disalin per user saat registrasi (D-20).
export async function seedInviteCode(prisma: PrismaClient): Promise<string | null> {
  if ((await prisma.inviteCode.count()) > 0) return null;
  const code = randomBytes(8).toString('hex').toUpperCase();
  await prisma.inviteCode.create({ data: { code } });
  return code;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const prisma = new PrismaClient();
  const code = await seedInviteCode(prisma);
  console.log(code ? `Kode undangan owner: ${code}` : 'Kode undangan sudah ada, seed dilewati.');
  await prisma.$disconnect();
}
