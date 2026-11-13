import { randomBytes } from "node:crypto";
import type { PrismaClient } from "@prisma/client";
import type { FastifyInstance } from "fastify";
import { loadConfig } from "../src/config.js";
import { buildApp } from "../src/server.js";

export function buildTestApp(deps: Parameters<typeof buildApp>[1] = {}) {
  return buildApp(loadConfig(process.env), deps);
}

export async function resetDb(prisma: PrismaClient) {
  const tables = await prisma.$queryRaw<{ tablename: string }[]>`
    SELECT tablename FROM pg_tables
    WHERE schemaname = 'public' AND tablename <> '_prisma_migrations'`;
  const names = tables.map((t) => `"${t.tablename}"`).join(", ");
  await prisma.$executeRawUnsafe(`TRUNCATE ${names} CASCADE`);
}

export async function createInvite(prisma: PrismaClient, expiresAt?: Date) {
  const code = randomBytes(8).toString("hex");
  await prisma.inviteCode.create({ data: { code, expiresAt } });
  return code;
}

export const PASSWORD = "rahasia123";

export async function createUser(
  app: FastifyInstance,
  email = "uji@example.test",
) {
  const res = await app.inject({
    method: "POST",
    url: "/api/v1/auth/register",
    payload: {
      name: "Pengguna Uji",
      email,
      password: PASSWORD,
      inviteCode: await createInvite(app.prisma),
    },
  });
  if (res.statusCode !== 201) throw new Error(`createUser gagal: ${res.body}`);
  return res.json() as {
    accessToken: string;
    refreshToken: string;
    user: { id: string };
  };
}

export function authHeader(accessToken: string) {
  return { authorization: `Bearer ${accessToken}` };
}
