# Kode undangan dari aplikasi (AUTH-07) — design

Status: draft, menunggu persetujuan owner (kontrak API baru + env baru).

## Kebutuhan owner (2026-11-17)

- Owner ingin membuat kode undangan **dari aplikasi**, dari mana saja, tanpa membuka database atau Prisma Studio (Studio tidak punya login, jadi tidak boleh dibuka ke publik).
- Owner dikenali dari **`OWNER_EMAIL` di `.env` mini PC** (tanpa ubah database). Kosong = tidak ada owner, menu tidak muncul.
- Kode **berlaku 7 hari**; lewat itu hangus (registrasi sudah menolak kode kedaluwarsa lewat `validInviteWhere`).
- **Tidak ada** batas jumlah user di server.

## Backend

- `config.ts`: `OWNER_EMAIL: z.email().optional()`; dibandingkan tanpa beda huruf besar/kecil.
- `GET /me` tambah `isOwner: boolean`.
- Modul baru `invites` (route tipis, service menerima `userId` + `ownerEmail`):
  - `GET /invites` → `{ items: Invite[] }`, kode buatan owner, terbaru dulu, maks. 20.
  - `POST /invites` → 201 `Invite`. Kode = `randomBytes(8).toString('hex').toUpperCase()` (sama dengan seed), `createdById` = owner, `expiresAt` = sekarang + 7 hari.
  - `Invite = { code, createdAt, expiresAt, usedAt, usedByName }`.
  - Bukan owner → **404** (endpoint dianggap tidak ada, pola "data user lain = 404").
- Kode tidak pernah ditulis ke log.

## Mobile

- Profil: baris **"Kode undangan"** (ikon `key_rounded`) hanya jika `me.isOwner`.
- Layar **Kode undangan** (`/undangan`): tombol `Buat kode`; daftar kartu `FrameCard`: kode (`titleMedium`, angka tabular), status:
  - belum dipakai & berlaku: `Berlaku sampai <tgl>` + tombol ikon salin (`Clipboard`, SnackBar `Kode disalin`);
  - dipakai: `Dipakai <nama>`;
  - lewat: `Kedaluwarsa`.
- Kosong: "Belum ada kode. Buat satu buat ngajak teman." Loading/error memakai `ListSkeleton`/`ErrorState`.

## Di luar cakupan

Cabut kode, batas jumlah user, kirim kode lewat WA/share sheet, lebih dari satu owner.
