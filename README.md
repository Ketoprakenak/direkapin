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

## Menjalankan aplikasi di laptop

Butuh Flutter 3 dan Android SDK. Dari folder `mobile/`:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run --dart-define=API_URL=http://<ip-laptop>:3000
```

HP dan laptop harus satu jaringan. HTTP hanya berlaku di build debug.

## Merilis APK

Push tag `vX.Y.Z` menjalankan `.github/workflows/release.yml`: analyze, test, build APK bertanda tangan, lalu terbit di GitHub Releases. Versi APK diambil dari tag.

Sekali saja, buat keystore dari folder di luar repo:

```bash
keytool -genkeypair -v -keystore direkapin.jks -keyalg RSA -keysize 2048 -validity 10000 -alias direkapin
base64 -w0 direkapin.jks
```

**Simpan `direkapin.jks` dan passwordnya di tempat aman, di luar repo.** Kalau hilang, update berikutnya tidak bisa dipasang di atas aplikasi lama.

Isi di GitHub, Settings > Secrets and variables > Actions:

| Secret | Isi |
|---|---|
| `KEYSTORE_BASE64` | Hasil `base64 -w0` di atas |
| `KEYSTORE_PASSWORD` | Password keystore |
| `KEY_ALIAS` | `direkapin` |
| `KEY_PASSWORD` | Password kunci |

Setiap rilis:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Setelah terbit, ubah `LATEST_APK_VERSION` di `.env` mini PC lalu jalankan ulang `api`. Banner update di aplikasi membaca nilai itu.

## Menjalankan di mini PC

Butuh Docker dan Docker Compose. Dari root repo:

1. Salin `.env.example` ke `.env` dan isi semua nilainya, dengan host `db` di `DATABASE_URL`.
2. Jalankan:

```bash
docker compose up -d --build
docker compose exec api node dist/prisma/seed.js
```

Migrasi jalan otomatis saat container `api` start. Tunnel Cloudflare menyusul di Slice 8, jadi sebelum itu API belum bisa diakses dari luar.
