# Direkapin

Aplikasi Android pencatat keuangan harian dan catatan kegiatan dalam satu kalender.
Kebutuhan lengkap ada di [docs/PRD.md](docs/PRD.md).

## Di mana semuanya jalan

- **Laptop:** ngoding dan test, memakai PostgreSQL 16 lokal berisi data palsu. Tidak butuh Docker.
- **Mini PC:** menjalankan API dan database asli di Docker, 24 jam.

## Menjalankan backend di laptop

Butuh Node.js 22 dan PostgreSQL 16.

1. Salin `.env.example` ke `backend/.env`, lalu sesuaikan:
   - `DATABASE_URL=postgresql://postgres:<password>@localhost:5432/direkapin`
   - `NODE_ENV=development`
   - `UPLOAD_DIR`, `ARCHIVE_DIR`, `BACKUP_DIR` ke folder lokal, misalnya `./data/uploads`
2. Dari folder `backend/`:

```bash
npm install
npx prisma migrate deploy
npx prisma db seed
npm run dev
```

Seed menampilkan kode undangan owner satu kali di terminal. API jalan di `http://localhost:3000/api/v1/health`.

## Test dan lint backend

```bash
npm test
npm run lint
```

`npm test` menghapus dan membuat ulang database `direkapin_test` setiap kali jalan. Test hanya mau jalan ke PostgreSQL lokal.

## Menjalankan di mini PC

Butuh Docker dan Docker Compose. Dari root repo:

1. Salin `.env.example` ke `.env` dan isi semua nilainya, dengan host `db` di `DATABASE_URL`.
2. Jalankan:

```bash
docker compose up -d --build
docker compose exec api node dist/prisma/seed.js
```

Migrasi jalan otomatis saat container `api` start. Tunnel Cloudflare menyusul di Slice 8, jadi sebelum itu API belum bisa diakses dari luar.
