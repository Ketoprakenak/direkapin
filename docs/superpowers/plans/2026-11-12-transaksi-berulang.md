# Transaksi berulang (FIN-15) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Aturan transaksi bulanan (masuk/keluar) yang muncul sebagai "Jatuh tempo" di Beranda dan baru tercatat setelah user menekan Catat (atau dilewati).

**Architecture:** Tabel baru `recurring_transactions` dengan penanda `lastHandledMonth`; jatuh tempo dihitung saat diminta (tanpa job). Modul backend baru `recurring` memakai ulang validasi & pembuatan transaksi dari modul `transactions`. Mobile: layar daftar/form aturan di Profil dan kartu Jatuh tempo di Beranda.

**Tech Stack:** Fastify 5 + Zod + Prisma 6 (PostgreSQL 16), vitest; Flutter 3 (Riverpod generator, freezed, go_router).

**Spec:** `docs/superpowers/specs/2026-11-12-transaksi-berulang-design.md`

## Global Constraints

- Tanpa dependency baru.
- `schema.prisma` hanya ditambah model `RecurringTransaction` (+ relasi balik di User/Wallet/Category); model lain tidak berubah. Migrasi baru ter-commit nanti oleh owner dan harus jalan di DB kosong.
- `openapi.yaml` hanya ditambah path `/recurring*` dan schema terkait.
- Semua query difilter `userId` dari token; milik user lain → 404.
- Nominal BigInt Rupiah, JSON integer. Bulan `YYYY-MM`, tanggal `YYYY-MM-DD`; hari jatuh tempo dan "hari ini" dihitung di zona waktu user.
- `dayOfMonth` 1–31; 29–31 jatuh ke hari terakhir bulan pendek. `endMonth` null = terus; `endMonth ≥ startMonth`.
- Jenis hanya `INCOME` / `EXPENSE`. Kategori harus sesuai jenis; dompet harus aktif (pakai pemeriksaan modul transaksi).
- Catat/Lewati hanya untuk kejadian berikutnya yang sudah jatuh tempo; selain itu 409 `CONFLICT`. Catat atomik (transaksi + maju `lastHandledMonth` dalam satu `$transaction` dengan syarat `lastHandledMonth` belum berubah).
- Mobile: tidak hardcode warna/ukuran; format lewat `core/format/`; navigasi lewat nama route; setiap layar menangani loading/kosong/error; bagian utama memakai `FrameCard` (`lib/core/widgets/frame.dart`).
- Tidak ada commit (owner commit setelah uji HP); `dart format`/format hanya file yang disentuh.

## Review Focus

1. Tap Catat dua kali cepat / dua HP → hanya satu transaksi; yang kedua 409 → test backend Task 2.
2. Aturan tanggal 31 di Februari dan bulan 30 hari → jatuh tempo hari terakhir → unit test Task 1.
3. Bulan terlewat (aturan mulai 3 bulan lalu, belum pernah dicatat) → muncul kejadian tertua dulu, setelah dilewati muncul berikutnya → test Task 2.
4. Zona waktu: jam 23:30 WIB tanggal jatuh tempo (masih 16:30 UTC) → sudah jatuh tempo → test Task 1.
5. Kategori/dompet dihapus/diarsip setelah aturan dibuat → Catat ditolak dengan pesan validasi, bukan 500 → test Task 2.

---

### Task 1: Model + logika jatuh tempo + CRUD aturan (backend)

**Files:**
- Modify: `backend/prisma/schema.prisma` (model baru + relasi balik), new migration `backend/prisma/migrations/<timestamp>_recurring_transactions/`
- Create: `backend/src/modules/recurring/recurring.schemas.ts`, `recurring.service.ts`, `recurring.routes.ts`, `recurring.test.ts`, `recurring.dates.ts` (+ `recurring.dates.test.ts`)
- Modify: `backend/src/server.ts` (daftar route), `docs/openapi.yaml`

**Interfaces:**
- Produces:
  - `nextOccurrence(rule: { dayOfMonth: number; startMonth: string; endMonth: string | null; lastHandledMonth: string | null }): { month: string; dueDate: string } | null` (murni, di `recurring.dates.ts`).
  - `isDue(dueDate: string, today: string): boolean`.
  - Respons aturan `Recurring`: `{ id, type, amount, note, dayOfMonth, startMonth, endMonth, lastHandledMonth, wallet: WalletRef, category: CategoryRef, next: { month, dueDate } | null }` (ref sama bentuknya dengan respons transaksi).
  - Routes: `GET/POST /recurring`, `PATCH/DELETE /recurring/:id`.

- [ ] **Step 1: Test gagal** — `recurring.dates.test.ts`: `nextOccurrence` untuk start `2026-01` day 31 → `{month:'2026-01', dueDate:'2026-01-31'}`; lastHandled `2026-01` → `2026-02-28`; 2028-02 → `2028-02-29`; endMonth `2026-01` & lastHandled `2026-01` → null; startMonth di masa depan tetap dikembalikan (dueDate di masa depan). `isDue('2026-11-05','2026-11-05')` true, `('2026-11-06','2026-11-05')` false.
  `recurring.test.ts` (pola helper test modul lain): POST sukses 201 dengan `next`; validasi: amount ≤ 0, dayOfMonth 0/32, endMonth < startMonth, kategori jenis lain, dompet arsip → 400; GET hanya milik sendiri; PATCH/DELETE milik user lain → 404; tanpa token 401; DELETE tidak menghapus transaksi yang sudah tercatat.
- [ ] **Step 2:** `npm test -- recurring` → FAIL.
- [ ] **Step 3: Implementasi** model, migrasi (`npx prisma migrate dev --name recurring_transactions`), schemas (Zod, pesan Indonesia), service (pakai pemeriksaan dompet/kategori yang sudah ada di `transactions.service.ts`; ekspor bila perlu tanpa mengubah perilaku), routes, openapi.
- [ ] **Step 4:** `npm run lint` + `npm test` → PASS.

### Task 2: Jatuh tempo, Catat, Lewati (backend)

**Files:** `backend/src/modules/recurring/*` (lanjutan), `docs/openapi.yaml`

**Interfaces:**
- Consumes: `nextOccurrence`, `isDue`, `getTimezone` (`me.service.ts`), pembuatan transaksi dari `transactions.service.ts` / `toTransactionResponse`.
- Produces: `GET /recurring/due` → `[{ recurring: Recurring, month, dueDate }]` urut `dueDate`; `POST /recurring/:id/record` body `{ month, amount?, occurredAt?, walletId?, note? }` → 201 `Transaction`; `POST /recurring/:id/skip` body `{ month }` → 204.

- [ ] **Step 1: Test gagal:**
  - due: aturan jatuh tempo hari ini muncul; besok tidak; milik user lain tidak; aturan selesai (lewat endMonth) tidak; zona waktu (`now` 2026-11-05T16:30Z, user Asia/Jakarta, day 5 → muncul; day 6 → tidak).
  - record: 201, transaksi tersimpan dengan nominal aturan (atau override), `occurredAt` default = dueDate pukul 12:00 waktu user, `lastHandledMonth` maju; muncul di `/transactions` & dashboard; `month` bukan kejadian berikutnya → 409; kejadian belum jatuh tempo → 409; panggil dua kali bersamaan (`Promise.all`) → satu 201, satu 409, satu transaksi di DB; dompet diarsip setelah aturan dibuat → 400 validasi; milik user lain → 404.
  - skip: 204, `lastHandledMonth` maju, tidak ada transaksi; bulan terlewat: aturan mulai 3 bulan lalu → due menampilkan bulan tertua, setelah skip menampilkan bulan berikutnya.
- [ ] **Step 2:** FAIL.
- [ ] **Step 3: Implementasi.** Klaim kejadian dengan `updateMany({ where: { id, userId, lastHandledMonth: <nilai lama> }, data: { lastHandledMonth: month } })` di dalam `prisma.$transaction` interaktif bersama `transaction.create`; `count === 0` → 409. Validasi dompet/kategori sebelum klaim.
- [ ] **Step 4:** `npm run lint` + `npm test` → PASS.

### Task 3: Mobile — data layer + layar aturan

**Files:**
- Create: `mobile/lib/features/recurring/data/recurring_models.dart` (+ generated), `recurring_api.dart`; `providers/recurring_providers.dart`; `presentation/recurring_list_screen.dart`, `presentation/recurring_form_screen.dart`
- Modify: `mobile/lib/core/router/router.dart` (`Routes.recurring = 'recurring'`, `Routes.recurringForm = 'recurringForm'`, pakai helper `_page`), `mobile/lib/features/settings/presentation/profile_screen.dart` (baris "Transaksi berulang" di grup menu kedua, ikon `Icons.event_repeat_rounded`)
- Test: `mobile/test/features/recurring/recurring_screens_test.dart`

**Interfaces:**
- Produces: `Recurring` (freezed, field = openapi), `RecurringDue { Recurring recurring; String month; String dueDate }`; `recurringListProvider`, `recurringDueProvider`; `RecurringApi.list/create/update/delete/due/record/skip`.

- [ ] **Step 1: Test gagal:** daftar kosong → EmptyState; daftar berisi → nama kategori, nominal, "Tiap tanggal 5"; FAB → form; simpan form valid → POST body benar (`dayOfMonth`, `startMonth`, `endMonth` null bila tidak diisi) lalu kembali & daftar ter-refresh; validasi nominal/kategori kosong; tap item → form terisi → PATCH; hapus → dialog konfirmasi → DELETE.
- [ ] **Step 2:** FAIL.
- [ ] **Step 3: Implementasi.** Form memakai `RupiahInputFormatter` dan `CategoryGrid` yang sudah ada, pilihan dompet seperti di `transaction_form_screen.dart`; tanggal 1–31 lewat dropdown; bulan mulai/berakhir lewat pemilih bulan yang sudah ada di app (cari; jika tidak ada, `showDatePicker` lalu ambil `YYYY-MM`). Item daftar dalam `FrameCard`.
- [ ] **Step 4:** `flutter analyze` + `flutter test` → PASS.

### Task 4: Mobile — kartu Jatuh tempo di Beranda

**Files:**
- Modify: `mobile/lib/features/dashboard/presentation/dashboard_screen.dart` (widget `_RecurringDue` sebelum blok "Hari ini"), `mobile/lib/features/transaction/providers/transaction_providers.dart` (`refreshMoney` meng-invalidate `recurringDueProvider` dan `recurringListProvider`)
- Create: `mobile/lib/features/recurring/presentation/widgets/record_sheet.dart`
- Test: `mobile/test/features/recurring/recurring_due_test.dart`

**Interfaces:**
- Consumes: `recurringDueProvider`, `RecurringApi.record/skip` (Task 3).

- [ ] **Step 1: Test gagal:** tidak ada due → kartu tidak tampil; ada due → `FrameCard` "Jatuh tempo" berisi kategori, nominal, tanggal; **Catat** → sheet dengan nominal & tanggal default → simpan → POST record body `{month, amount, occurredAt}` → baris hilang & `refreshMoney` terpanggil (dashboard di-fetch ulang); **Lewati** → dialog konfirmasi → POST skip; 409 dari server → SnackBar pesan server dan daftar di-refresh; error memuat due → kartu disembunyikan (Beranda tetap jalan).
- [ ] **Step 2:** FAIL.
- [ ] **Step 3: Implementasi.**
- [ ] **Step 4:** `flutter analyze` + `flutter test` → PASS.

### Task 5: Docs + verifikasi + APK

- [ ] `docs/DECISIONS.md` D-67 (keputusan spec + "Keputusan Claude"); `docs/PRD.md` FIN-15 catatan konfirmasi/bulanan; `docs/DESIGN.md` (layar Transaksi berulang, kartu Jatuh tempo, salinan teks); `docs/TASKS.md` slice baru "Slice 11 — Transaksi berulang (FIN-15)" dicentang. Pertahankan line ending tiap file.
- [ ] `backend/`: `npm run lint`, `npm test`; buktikan migrasi jalan dari kosong dengan `npx prisma migrate deploy` ke database kosong **baru/terpisah** (mis. DB test yang dibuat ulang oleh setup test). Jangan reset DB dev owner.
- [ ] `mobile/`: `flutter analyze`, `flutter test`, `flutter build apk --debug --dart-define=API_URL=http://192.168.53.6:3000` → `√ Built`.
