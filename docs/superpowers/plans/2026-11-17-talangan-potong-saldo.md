# Utang ditalangin memotong "Bisa digunakan" Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Sisa utang ditalangin langsung mengurangi "Bisa digunakan", sementara Saldo total baru turun saat cicilan dibayar.

**Architecture:** Hanya dashboard yang berubah: `receivableRemaining` diberi filter "ditalangin saja", hasilnya dikurangkan dari `availableBalance`, dan `totalBalance` dihitung dari saldo dompet mentah. Mobile menambah keterangan di baris Bisa digunakan.

**Tech Stack:** Fastify 5 + Zod + Prisma 6, vitest; Flutter 3 (freezed).

**Spec:** `docs/superpowers/specs/2026-11-17-talangan-potong-saldo-design.md`

## Global Constraints

- Tanpa dependency baru, tanpa perubahan `schema.prisma`, tanpa migrasi.
- Field baru `frontedPayableRemaining: int`; `payableRemaining` tetap = semua utang.
- Copy persis: `Sudah dipotong utang ditalangin Rp…`.
- Commit hanya jika owner minta.

## Review Focus

1. Pinjam tunai → `availableBalance` naik sebesar pinjaman, tidak dipotong → test Task 1.
2. Bayar cicilan talangan → `totalBalance` turun, `availableBalance` tetap → test Task 1.
3. Talangan lebih besar dari isi dompet → `availableBalance` negatif, tampil merah → test Task 1 + Task 2.
4. Transaksi pinjaman dihapus → catatannya ikut dihitung ditalangin → test Task 1.
5. Mode sembunyi saldo → keterangan juga tersembunyi → test Task 2.

---

### Task 1: Backend dashboard

**Files:**
- Modify: `backend/src/modules/receivables/receivables.service.ts` (`receivableRemaining`), `backend/src/modules/dashboard/dashboard.schemas.ts`, `dashboard.service.ts`, `backend/src/modules/receivables/receivables.test.ts`
- Modify: `docs/openapi.yaml` (dashboard), `docs/DECISIONS.md` (D-81, jaga CRLF), `docs/PRD.md` (FIN-20 kalimat Saldo), `docs/TASKS.md` (Slice 23)

**Interfaces:**
- Produces: `receivableRemaining(prisma, userId, direction, frontedOnly = false)`; `frontedOnly` menambah `loanTransactionId: null` di filter `receivable` (dua agregat).

- [ ] **Step 1: Test gagal** (describe `payables` FIN-20; dompet BCA saldo awal 100.000):
  - talangan 50.000 → dashboard `totalBalance 100_000`, `availableBalance 50_000`, `frontedPayableRemaining 50_000`.
  - bayar 20.000 → `totalBalance 80_000`, `availableBalance 50_000`, `frontedPayableRemaining 30_000`.
  - pinjam tunai 1.000.000 (talangan tadi tetap) → `totalBalance 1_080_000`, `availableBalance 1_050_000`, `frontedPayableRemaining 30_000`.
  - talangan 500.000 tambahan → `availableBalance` negatif (`1_050_000 − 500_000` = 550_000; pakai dompet 0 bila perlu untuk negatif).
  - hapus transaksi pinjaman → `frontedPayableRemaining` ikut menjumlah utang tunai itu.
  - test dashboard lama (`'dashboard: piutang dan utang dipisah …'`) diperbarui: `availableBalance` dipotong talangan.
- [ ] **Step 2:** `npx vitest run src/modules/receivables src/modules/dashboard src/modules/savings` → FAIL.
- [ ] **Step 3:** Implement; `totalBalance` = `wallets.totalBalance + Σ savings` (nilai mentah), `availableBalance` = `wallets.totalBalance − fronted`.
- [ ] **Step 4:** `npm test` → PASS; lint bersih. Docs.

### Task 2: Mobile sheet Saldo total

**Files:**
- Modify: `mobile/lib/features/dashboard/data/dashboard_models.dart` (`@Default(0) int frontedPayableRemaining`), `mobile/lib/features/savings/presentation/savings_sheet.dart`, `mobile/test/helpers/fake_server.dart` (`dashboardJson(frontedPayableRemaining:)`), `mobile/test/features/savings/savings_test.dart`

- [ ] **Step 1: Test gagal:** `frontedPayableRemaining: 50000` → teks `Sudah dipotong utang ditalangin Rp50.000` di baris Bisa digunakan; `0` → tidak ada; mode sembunyi → tidak ada; `availableBalance` negatif → `−Rp…`.
- [ ] **Step 2:** `flutter test test/features/savings` → FAIL.
- [ ] **Step 3:** Implement (keterangan `labelSmall` di bawah label Bisa digunakan); codegen.
- [ ] **Step 4:** test → PASS; `flutter analyze` bersih; APK debug ke IP WiFi laptop, owner uji.
