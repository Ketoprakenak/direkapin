# Kode undangan dari aplikasi (AUTH-07) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Owner membuat dan melihat kode undangan dari layar Profil, tanpa membuka database.

**Architecture:** Owner = user dengan email sama dengan `OWNER_EMAIL` (env, opsional). Modul backend baru `invites` (GET/POST) yang membalas 404 untuk selain owner; `GET /me` menambah `isOwner`. Mobile: layar `Kode undangan` di belakang menu Profil yang hanya tampil untuk owner.

**Tech Stack:** Fastify 5 + Zod + Prisma 6, vitest; Flutter 3 (Riverpod generator, freezed, go_router).

**Spec:** `docs/superpowers/specs/2026-11-17-kode-undangan-design.md`

## Global Constraints

- Tanpa dependency baru; tanpa perubahan `schema.prisma` (tabel `invite_codes` sudah punya `createdById`, `expiresAt`).
- `OWNER_EMAIL` opsional; ditambahkan ke `.env.example` dengan nilai contoh `owner@example.test`. Email owner asli tidak pernah masuk repo, test, atau log.
- Bukan owner → 404 `NOT_FOUND` "Data tidak ditemukan".
- Masa berlaku kode: 7 × 86.400.000 ms.
- Copy persis: `Kode undangan`, `Buat kode`, `Berlaku sampai <tgl>`, `Dipakai <nama>`, `Kedaluwarsa`, `Kode disalin`, `Belum ada kode. Buat satu buat ngajak teman.`
- Mobile: `FrameCard`, warna tema, format tanggal lewat `core/format/dates.dart`. Balikin churn EOL build_runner. Commit hanya jika owner minta.

## Review Focus

1. `OWNER_EMAIL` beda huruf besar/kecil dengan email akun → tetap owner → test Task 1.
2. `OWNER_EMAIL` kosong → `isOwner: false` untuk semua, `/invites` 404 → test Task 1.
3. Kode buatan app dipakai daftar → `POST /auth/register` sukses, kode tercatat dipakai; setelah 7 hari ditolak → test Task 1.
4. User biasa membuka `/undangan` lewat deep link → layar tidak bocor data (server 404 → `ErrorState`) → test Task 2.
5. Tap `Buat kode` dua kali cepat → tombol nonaktif saat proses, satu kode per tap selesai → test Task 2.

---

### Task 1: Backend

**Files:**
- Modify: `backend/src/config.ts`, `.env.example`, `backend/test/helpers.ts` (env test `OWNER_EMAIL=a@example.test` jika helper menyetel env), `backend/src/modules/me/me.schemas.ts`, `me.service.ts`, `me.routes.ts`, `backend/src/server.ts`
- Create: `backend/src/modules/invites/invites.schemas.ts`, `invites.service.ts`, `invites.routes.ts`, `invites.test.ts`
- Modify: `docs/openapi.yaml` (`/invites`, `Invite`, `User.isOwner`), `docs/PRD.md` (AUTH-07), `docs/DECISIONS.md` (D-80), `docs/TASKS.md` (Slice 22)

**Interfaces:**
- Produces: `isOwner(email: string, ownerEmail?: string): boolean` di `invites.service.ts`.
- Produces: `listInvites(prisma, userId, ownerEmail?)`, `createInvite(prisma, userId, ownerEmail?, now = new Date())`.

- [ ] **Step 1: Test gagal** (`invites.test.ts`, app test dengan `OWNER_EMAIL` = email user A dalam huruf besar):
  - `owner`: `GET /me` → `isOwner: true`; `POST /invites` → 201, `code` 16 karakter hex huruf besar, `expiresAt` − `createdAt` = 7 hari; `GET /invites` → item itu, `usedAt: null`.
  - `dipakai`: `POST /auth/register` dengan kode itu → 201; `GET /invites` → `usedByName` = nama user baru.
  - `kedaluwarsa`: `createInvite(..., now = 8 hari lalu)` lalu register → 422 `INVITE_INVALID`.
  - `bukan owner`: user B → `isOwner: false`, `GET`/`POST /invites` → 404.
  - unit `isOwner('A@x.test', 'a@x.test')` true; `isOwner('a@x.test', undefined)` false.
- [ ] **Step 2:** `npx vitest run src/modules/invites` → FAIL.
- [ ] **Step 3:** Implement. Cek owner: `findUnique` user by `userId`, bandingkan email; bukan owner → `AppError('NOT_FOUND', 404, 'Data tidak ditemukan')`.
- [ ] **Step 4:** `npm test` → PASS; `npm run lint` bersih. Docs sesuai spec.

### Task 2: Mobile

> Sebelum mulai: mockup (show_widget) layar Kode undangan + baris Profil, tunggu "gas".

**Files:**
- Create: `mobile/lib/features/invite/data/invite_models.dart` (freezed `Invite`), `invite_api.dart` (`list()`, `create()`), `providers/invite_providers.dart` (`invitesProvider`), `presentation/invites_screen.dart`
- Modify: model user/me (`isOwner`, `@Default(false)`), `mobile/lib/core/router/router.dart` (`Routes.invites` `/undangan`), `mobile/lib/features/settings/presentation/profile_screen.dart`, `mobile/test/helpers/fake_server.dart` (`meJson` `isOwner`)
- Test: `mobile/test/features/invite/invite_test.dart`

- [ ] **Step 1: Widget test gagal:**
  - Profil dengan `isOwner: true` → baris `Kode undangan`; `false` → tidak ada.
  - Layar: kosong → teks kosong persis; 3 kartu (berlaku/dipakai/kedaluwarsa) → `Berlaku sampai …` + ikon salin, `Dipakai Budi`, `Kedaluwarsa`; salin → SnackBar `Kode disalin`.
  - `Buat kode` → POST `/invites` sekali, daftar dimuat ulang; tombol nonaktif selama proses.
  - server 404 → `ErrorState`.
- [ ] **Step 2:** `flutter test test/features/invite` → FAIL.
- [ ] **Step 3:** Implement; codegen; format file yang disentuh saja.
- [ ] **Step 4:** test → PASS; `flutter analyze` bersih.

### Task 3: Verifikasi + APK debug

- [ ] `npm run lint`, `npm test`, `flutter analyze`, `flutter test` bersih.
- [ ] Owner menambah `OWNER_EMAIL=<email owner>` di `backend/.env` laptop (owner yang ketik), restart `npm run dev`, build APK debug ke IP WiFi laptop. Owner uji di HP.
- [ ] Rilis: owner menambah `OWNER_EMAIL` di `.env` mini PC sebelum deploy.
