# Bagi pengeluaran ke teman (FIN-21) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Dari pengeluaran, owner bisa "Bagi ke teman" dan hasilnya langsung jadi piutang yang menyimpan tautan ke pengeluaran asal.

**Architecture:** `Receivable.sourceTransactionId` (unik, `SET NULL`) menautkan piutang ke pengeluaran. Endpoint baru tidak perlu: `POST /receivables` menerima `sourceTransactionId`. Mobile memakai ulang form Catat piutang dalam mode "sumber" (judul/tanggal terisi, Bagi rata, batas total), dibuka dari form pengeluaran baru atau dari detail pengeluaran.

**Tech Stack:** Fastify 5 + Zod + Prisma 6 (PostgreSQL 16), vitest; Flutter 3 (Riverpod generator, freezed, go_router).

**Spec:** `docs/superpowers/specs/2026-11-16-bagi-pengeluaran-design.md`

## Global Constraints

- Tanpa dependency baru.
- `schema.prisma`: hanya `Receivable.sourceTransactionId String? @unique @db.Uuid` + `sourceTransaction Transaction? @relation("ReceivableSource", …, onDelete: SetNull)` dan `Transaction.receivableSource Receivable? @relation("ReceivableSource")`. Satu migrasi `<ts>_receivable_source`, ditulis tangan (pola `20261116090000_payables`), jangan `prisma format`.
- Semua query difilter `userId`; transaksi user lain di body → 400 (D-27).
- Copy persis: `Bagi ke teman`, `Bagi rata`, `Dari pengeluaran <kategori> Rp…`, `Dibagi ke teman`, `Bagian kamu Rp…`, `Pilih pengeluaran`, `Pengeluaran ini sudah dibagi`, `Melebihi nominal pengeluaran Rp…`, `Hanya untuk piutang`.
- Bagi rata: tiap teman `total ~/ (n + 1)`; sisa pembulatan milik owner.
- Mobile: `FrameCard`/`FrameBox`, warna tema, format lewat `core/format/`, `refreshMoney(ref)`. Balikin churn EOL hasil build_runner. Tidak ada commit sampai owner minta.

## Review Focus

1. Kirim ulang form bagi (timeout lalu Simpan lagi) → satu piutang, bukan 400 "sudah dibagi" → test Task 1 (`clientId` sama dengan `sourceTransactionId`).
2. Pengeluaran dihapus setelah dibagi → piutang tetap, `source: null`, cicilan tetap → test Task 1.
3. Total teman tepat sama dengan nominal pengeluaran → boleh (bagian owner Rp0) → test Task 1.
4. Simpan pengeluaran berhasil tapi form bagi ditutup tanpa simpan → pengeluaran tetap tersimpan, tombol "Bagi ke teman" muncul di detailnya → test Task 3.
5. Bagi rata dengan 0 teman di baris atau nominal pengeluaran Rp1 → tidak crash; bagian teman Rp0 ditolak validasi "Nominal harus lebih dari 0" → test Task 2.

---

### Task 1: Backend — tautan sumber

**Files:**
- Modify: `backend/prisma/schema.prisma`; Create: `backend/prisma/migrations/<ts>_receivable_source/migration.sql`
- Modify: `backend/src/modules/receivables/receivables.schemas.ts`, `receivables.service.ts`, `receivables.test.ts`
- Modify: `backend/src/modules/transactions/transactions.schemas.ts`, `transactions.service.ts` (`receivableId`)
- Modify: `docs/openapi.yaml`, `docs/PRD.md` (FIN-21), `docs/DECISIONS.md` (D-79, jaga CRLF), `docs/TASKS.md` (Slice 21)

**Interfaces:**
- Produces: `createReceivableBody.sourceTransactionId: z.uuid('Pilih pengeluaran').optional()`; `superRefine`: dengan `PAYABLE` → `sourceTransactionId: 'Hanya untuk piutang'`.
- Produces: `receivableResponse.source: { transactionId, amount, categoryName } | null` (include `sourceTransaction: { select: { id, amount, category: { select: { name } } } }`).
- Produces: `transactionResponse.receivableId: string | null` (include `receivableSource: { select: { id: true } }` di `transactionInclude`).

- [ ] **Step 1: Test gagal** (describe baru `'bagi pengeluaran (FIN-21)'`; buat EXPENSE Makan 200.000 via `POST /transactions`):
  - `bagi`: POST `/receivables` `{title:'Makan', date:'2026-11-16', sourceTransactionId, debtors:[{name:'Budi',amount:66_666},{name:'Andi',amount:66_666}]}` → 201, `source` = `{transactionId, amount:200_000, categoryName:'Makan'}`; `GET /transactions/:id` → `receivableId` = id piutang.
  - `batas`: Σ 200_001 → 400 `details.debtors` `'Melebihi nominal pengeluaran Rp200.000'`; Σ tepat 200_000 → 201.
  - `sekali`: bagi kedua kali (clientId beda) → 400 `details.sourceTransactionId` `'Pengeluaran ini sudah dibagi'`; kiriman ulang `clientId` sama → 201, id sama.
  - `sumber salah`: transaksi INCOME, transaksi user lain, `direction:'PAYABLE'` → 400 `details.sourceTransactionId`.
  - `hapus pengeluaran`: setelah satu cicilan, `DELETE /transactions/:id` → GET piutang `source: null`, `paid` tetap.
- [ ] **Step 2:** `npx vitest run src/modules/receivables` → FAIL.
- [ ] **Step 3:** Implement di `createReceivable`: urutan: `replay()` lebih dulu (kiriman ulang menang atas "sudah dibagi"), lalu `findFirst({ id, userId, type: 'EXPENSE' })` (tidak ada → 400), lalu cek Σ, lalu simpan `sourceTransactionId`. Unique violation tanpa replay yang cocok → 400 "sudah dibagi" (bukan 500).
- [ ] **Step 4:** `npm test` → PASS; `npm run lint` bersih. Docs sesuai spec.

### Task 2: Mobile — form Bagi ke teman

> Sebelum mulai: mockup (show_widget) form Bagi ke teman + tombol di detail pengeluaran, tunggu "gas".

**Files:**
- Modify: `mobile/lib/features/receivable/data/receivable_models.dart` (freezed `ReceivableSourceRef {transactionId, amount, categoryName}`, field `ReceivableSourceRef? source`), `mobile/lib/features/transaction/data/transaction_models.dart` (`String? receivableId`)
- Create: `ReceivableSource` (class biasa, bukan freezed) di `receivable_models.dart`: `{transactionId, amount, categoryName, date}` — argumen form, `date` = `dateKey(occurredAt.toLocal())`.
- Modify: `mobile/lib/features/receivable/presentation/receivable_form_screen.dart` (param `source`), `mobile/lib/core/router/router.dart` (`extra` `ReceivableSource` → form bagi)
- Test: `mobile/test/features/receivable/receivable_test.dart`

**Interfaces:**
- Produces: `ReceivableFormScreen({Receivable? receivable, ReceivableDirection direction, ReceivableSource? source})`; `context.pushNamed(Routes.receivableForm, extra: ReceivableSource(...))`.
- Produces: `List<int> splitEvenly(int total, int friends)` (top-level di form, diuji unit) = `friends` kali `total ~/ (friends + 1)`.

- [ ] **Step 1: Test gagal:**
  - unit `splitEvenly(200000, 2)` → `[66666, 66666]`; `splitEvenly(1, 1)` → `[0]`.
  - form dengan `extra: ReceivableSource(transactionId:'t1', amount:200000, categoryName:'Makan', date:'2026-11-16')`: judul AppBar `Bagi ke teman`, field Judul berisi `Makan`, teks `Dari pengeluaran Makan Rp200.000`; isi 2 nama, tap `Bagi rata` → kedua Nominal `66.666`, teks `Bagian kamu Rp66.668`; Simpan → POST body berisi `sourceTransactionId: 't1'`, `date: '2026-11-16'`, debtors 66666 ×2.
  - total > 200.000 → teks error `Melebihi nominal pengeluaran Rp200.000` di form, tanpa write.
  - `splitEvenly` hasil 0 → validasi baris `Nominal harus lebih dari 0`.
- [ ] **Step 2:** `flutter test test/features/receivable` → FAIL.
- [ ] **Step 3:** Implement. Mode sumber: tanggal tetap bisa diubah; "Total piutang" diganti total + `Bagian kamu`; Bagi rata hanya tampil di mode sumber.
- [ ] **Step 4:** codegen, format, test → PASS.

### Task 3: Mobile — pintu masuk dari pengeluaran

**Files:**
- Modify: `mobile/lib/features/transaction/presentation/transaction_form_screen.dart` (switch + lanjut ke form bagi), `item_detail_screen.dart` (tombol/baris), `receivable_detail_screen.dart` (baris asal)
- Test: `mobile/test/features/transaction/` (file form & detail yang ada), `receivable_test.dart`

**Interfaces:**
- Consumes: `ReceivableSource`, `Routes.receivableForm` (Task 2); `Transaction.receivableId`.

- [ ] **Step 1: Test gagal:**
  - form pengeluaran baru, switch `Bagi ke teman` aktif, Simpan → POST `/transactions` lalu layar `Bagi ke teman` tampil dengan `Dari pengeluaran Makan Rp…`; switch tidak ada di mode Masuk, Transfer, dan saat edit.
  - detail EXPENSE `receivableId: null` → `OutlinedButton` `Bagi ke teman`; tap → form bagi. `receivableId: 'r1'` → teks `Dibagi ke teman`, tanpa tombol. INCOME → keduanya tidak ada.
  - detail piutang dengan `source` → teks `Dari pengeluaran Makan Rp200.000`; tap → route `transactionDetail`.
- [ ] **Step 2:** test → FAIL.
- [ ] **Step 3:** Implement. Form pengeluaran: setelah foto tersinkron, kalau switch aktif → `context.pushReplacementNamed(Routes.receivableForm, extra: ReceivableSource(...))` alih-alih `pop`. Snackbar "Transaksi tersimpan" tetap tampil.
- [ ] **Step 4:** test → PASS; `flutter analyze` bersih.

### Task 4: Verifikasi + APK debug

- [ ] `npm run lint`, `npm test`, `flutter analyze`, `flutter test` bersih.
- [ ] `npx prisma migrate deploy` di DB dev, restart `npm run dev`, `flutter build apk --debug --dart-define=API_URL=http://<IP WiFi laptop>:3000`. Owner uji di HP.
- [ ] Centang Slice 21 di `docs/TASKS.md` setelah owner OK.
