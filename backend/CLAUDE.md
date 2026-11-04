# Backend — konvensi

Baca juga `../CLAUDE.md` (aturan umum) dan `../docs/openapi.yaml` (kontrak).

## Struktur

```
backend/
├── prisma/
│   ├── schema.prisma
│   ├── migrations/
│   └── seed.ts                 # 1 kode undangan owner
├── src/
│   ├── server.ts               # buildApp() + listen; buildApp dipakai juga oleh test
│   ├── config.ts               # baca & validasi env dengan zod, gagal start jika kurang
│   ├── plugins/
│   │   ├── prisma.ts           # decorate app.prisma
│   │   ├── auth.ts             # verifikasi JWT → request.userId; decorator app.authenticate
│   │   ├── errors.ts           # setErrorHandler → format Error dari openapi.yaml
│   │   └── rate-limit.ts
│   ├── lib/
│   │   ├── app-error.ts        # class AppError(code, httpStatus, message, details?)
│   │   ├── money.ts            # BigInt <-> number
│   │   ├── dates.ts            # konversi zona waktu user, awal/akhir hari/minggu/bulan
│   │   ├── default-categories.ts  # template kategori bawaan (DESIGN.md), disalin saat registrasi
│   │   └── storage.ts          # simpan/hapus file di UPLOAD_DIR, path aman
│   ├── modules/
│   │   └── <modul>/            # auth, me, wallets, transfers, categories, transactions,
│   │       ├── <modul>.routes.ts    # activities, attachments, calendar, reports, dashboard, archives
│   │       ├── <modul>.schemas.ts   # zod: input & output, sama persis dengan openapi.yaml
│   │       ├── <modul>.service.ts   # logika bisnis, menerima userId eksplisit
│   │       └── <modul>.test.ts
│   └── jobs/
│       ├── scheduler.ts        # node-cron, TZ dari env
│       ├── backup.job.ts       # pg_dump harian 01:00, simpan 14 hari
│       └── archive.job.ts      # harian 02:00, idempoten: arsip M-2 yang belum ada/FAILED + bereskan yang kedaluwarsa
├── test/
│   └── helpers.ts              # buildTestApp(), createUser(), authHeader()
└── Dockerfile
```

## Pola wajib

- **Route tipis, service tebal.** Route: validasi (zod), ambil `request.userId`, panggil service, kembalikan hasil. Semua logika di service.
- **Service selalu menerima `userId`** sebagai argumen pertama dan memakainya di setiap `where`. Tidak ada query tanpa `userId` (kecuali auth dan job sistem).
- **Ambil-lalu-cek kepemilikan pakai `findFirst({ where: { id, userId } })`**. Tidak ketemu → `throw new AppError('NOT_FOUND', 404, 'Data tidak ditemukan')`.
- **Error** hanya lewat `AppError`. Error tak terduga → `INTERNAL_ERROR` 500, pesan generik, detail hanya di log.
- **Pesan error** bahasa Indonesia, aman ditampilkan ke user. `code` dari enum di `openapi.yaml`.
- **BigInt**: Prisma mengembalikan `bigint`; ubah ke `number` di lapisan output (`lib/money.ts`). Nominal maks. 999.999.999 aman.
- **Tanggal**: terima `occurredAt` ISO UTC. Untuk filter `from`/`to` (YYYY-MM-DD), konversi ke rentang UTC berdasarkan `user.timezone` di `lib/dates.ts`. Jangan pakai `new Date('YYYY-MM-DD')` mentah.
- **Saldo** dihitung dengan agregat SQL (`groupBy` / `$queryRaw` dengan parameter), bukan loop di JS.
- **Transaksi DB** (`prisma.$transaction`) untuk operasi multi-tabel: registrasi (user + dompet + kategori + pakai kode), hapus kategori (pindah transaksi ke "Lainnya"), job arsip.
- **File upload**: `@fastify/multipart` dengan `limits.fileSize = MAX_UPLOAD_BYTES`. Cek MIME dari isi file lewat `sharp().metadata()`, bukan dari header. Nama file di disk = `<userId>/<yyyy>/<mm>/<attachmentId>.<ext>`; jangan pernah memakai nama file dari client.
- **Hapus data dengan foto**: hapus record di DB dulu (dalam transaksi), lalu hapus file; kegagalan hapus file hanya di-log.
- **Arsip**: tandai `DOWNLOADED` dan hapus foto asli hanya setelah stream ZIP selesai utuh, bukan saat request masuk. ZIP dihapus saat `expiresAt`. ZIP gagal dibuat → status `FAILED`, `zipPath` null, foto asli tidak disentuh (D-22, D-23).
- **Logging**: pino bawaan Fastify. Jangan log password, token, atau isi body auth.

## Test

- Vitest + `app.inject()` (tidak perlu port). Database test terpisah (`direkapin_test`) di PostgreSQL laptop, di-reset per file test. Jangan pernah arahkan test ke database mini PC.
- Setiap endpoint minimal: 1 test sukses, 1 test validasi gagal, 1 test **akses data user lain → 404**.
- Test logika murni (saldo, streak, rentang tanggal, laporan) sebagai unit test service.
- Jangan mock Prisma; pakai database test sungguhan.

## Perintah

```bash
npm run dev          # tsx watch src/server.ts
npm test             # vitest run
npm run lint         # eslint . && tsc --noEmit
npm run build        # tsc → dist/
npx prisma migrate dev --name <nama>
npx prisma db seed
```
