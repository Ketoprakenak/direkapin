import { afterAll, beforeAll, beforeEach, describe, expect, it } from "vitest";
import {
  PASSWORD,
  buildTestApp,
  createUser,
  resetDb,
} from "../../../test/helpers.js";

const sent: { to: string; text: string }[] = [];
const app = buildTestApp({
  sendMail: async (to, _subject, text) => {
    sent.push({ to, text });
  },
});

beforeAll(() => app.ready());
beforeEach(async () => {
  sent.length = 0;
  await resetDb(app.prisma);
});
afterAll(() => app.close());

const post = (path: string, payload: object) =>
  app.inject({ method: "POST", url: `/api/v1/auth/${path}`, payload });

const EMAIL = "lupa@example.test";
const NEW_PASSWORD = "baruBanget9";

async function requestCode(email = EMAIL) {
  const res = await post("forgot-password", { email });
  expect(res.statusCode).toBe(200);
  // Email dikirim tanpa ditunggu; beri kesempatan promise-nya jalan.
  await new Promise((resolve) => setImmediate(resolve));
  return sent.at(-1)?.text.match(/\b(\d{6})\b/)?.[1];
}

describe("POST /auth/forgot-password + /auth/reset-password", () => {
  // Rate limit 10 per 15 menit per route berlaku lintas test di file ini; jaga total panggilan.
  it("validasi: email, format kode, password lemah", async () => {
    expect(
      (await post("forgot-password", { email: "bukan-email" })).statusCode,
    ).toBe(400);
    const res = await post("reset-password", {
      email: EMAIL,
      code: "12ab",
      newPassword: "pendek",
    });
    expect(res.statusCode).toBe(400);
    expect(Object.keys(res.json().error.details).sort()).toEqual([
      "code",
      "newPassword",
    ]);
  });

  it("kode benar: password diganti, sesi lama dicabut, password lama ditolak", async () => {
    const { refreshToken } = await createUser(app, EMAIL);
    const code = await requestCode();
    expect(sent.at(-1)?.to).toBe(EMAIL);
    expect(code).toMatch(/^\d{6}$/);

    const res = await post("reset-password", {
      email: EMAIL,
      code,
      newPassword: NEW_PASSWORD,
    });
    expect(res.statusCode).toBe(204);

    expect((await post("refresh", { refreshToken })).statusCode).toBe(401);
    expect(
      (await post("login", { email: EMAIL, password: PASSWORD })).statusCode,
    ).toBe(401);
    expect(
      (await post("login", { email: EMAIL, password: NEW_PASSWORD }))
        .statusCode,
    ).toBe(200);

    // Kode hanya sekali pakai.
    const again = await post("reset-password", {
      email: EMAIL,
      code,
      newPassword: "lainLagi99",
    });
    expect(again.statusCode).toBe(400);
  });

  it("email tidak terdaftar: balasan sama, tanpa email", async () => {
    const res = await post("forgot-password", {
      email: "tidakada@example.test",
    });
    expect(res.statusCode).toBe(200);
    expect(res.json()).toEqual({
      message: "Kalau email itu terdaftar, kode reset sudah dikirim.",
    });
    await new Promise((resolve) => setImmediate(resolve));
    expect(sent).toHaveLength(0);
  });

  it("kode salah 5 kali: kode hangus walau kemudian benar", async () => {
    await createUser(app, EMAIL);
    const code = await requestCode();
    const wrong = code === "000000" ? "111111" : "000000";
    for (let i = 0; i < 5; i++) {
      const res = await post("reset-password", {
        email: EMAIL,
        code: wrong,
        newPassword: NEW_PASSWORD,
      });
      expect(res.statusCode).toBe(400);
      expect(res.json().error.details).toEqual({
        code: "Kode salah atau sudah kedaluwarsa",
      });
    }
    const res = await post("reset-password", {
      email: EMAIL,
      code,
      newPassword: NEW_PASSWORD,
    });
    expect(res.statusCode).toBe(400);
  });

  it("kode kedaluwarsa dan kode lama setelah minta baru ditolak", async () => {
    await createUser(app, EMAIL);
    await requestCode();
    const newCode = await requestCode();
    // Kode lama dibatalkan saat minta kode baru (dicek di DB, hemat jatah rate limit).
    const active = await app.prisma.passwordReset.count({
      where: { usedAt: null },
    });
    expect(active).toBe(1);

    await app.prisma.passwordReset.updateMany({
      data: { expiresAt: new Date(Date.now() - 1000) },
    });
    const res = await post("reset-password", {
      email: EMAIL,
      code: newCode,
      newPassword: NEW_PASSWORD,
    });
    expect(res.statusCode).toBe(400);
  });
});
