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

Test restore backup butuh folder `bin` PostgreSQL di `PATH` (`pg_dump`, `pg_restore`, `psql`). Tanpa itu test tersebut dilewati.

Menjalankan job sekarang: `npm run job -- archive` atau `npm run job -- backup`.

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

### 1. Siapkan mesin

- Pasang Docker dan Docker Compose, lalu aktifkan Docker saat boot: `sudo systemctl enable docker`.
- Di BIOS, atur agar mini PC menyala sendiri setelah listrik kembali (biasanya "Restore on AC Power Loss").

### 2. Siapkan Cloudflare Tunnel

1. Pindahkan DNS domain `appdirekapin.my.id` ke Cloudflare.
2. Di Cloudflare Zero Trust, buka Networks > Tunnels dan buat tunnel jenis `cloudflared`.
3. Tambahkan public hostname `api.appdirekapin.my.id` dengan service `http://api:3000`.
4. Salin token tunnel untuk `CF_TUNNEL_TOKEN` di `.env`.

Tidak ada port yang perlu dibuka di router.

### 3. Jalankan

Salin `.env.example` ke `.env`, isi semua nilainya dengan host `db` di `DATABASE_URL`, lalu dari root repo:

```bash
docker compose up -d --build
docker compose exec api node dist/prisma/seed.js
curl https://api.appdirekapin.my.id/api/v1/health
```

Migrasi jalan otomatis saat container `api` start. Seed menampilkan kode undangan owner satu kali.

### Backup

Job di dalam `api` membuat `pg_dump` tiap hari pukul 01.00 ke `data/backups/` dan menyimpan 14 hari terakhir. Job arsip foto jalan pukul 02.00. Keduanya bisa dipicu manual:

```bash
docker compose exec api node dist/src/jobs/run.js backup
docker compose exec api node dist/src/jobs/run.js archive
```

**Salin folder `data/` ke disk eksternal atau cloud seminggu sekali (D-52).** Selama belum disalin, backup dan data asli ada di SSD yang sama, jadi disk rusak berarti semuanya hilang.

Uji restore tiap bulan ke database kosong. Ganti tanggal di nama file:

```bash
docker compose exec db createdb -U direkapin direkapin_restore
docker compose exec -T db pg_restore -U direkapin -d direkapin_restore --exit-on-error < data/backups/direkapin-2026-11-06.dump
docker compose exec db psql -U direkapin -d direkapin_restore -c "SELECT count(*) FROM transactions"
docker compose exec db dropdb -U direkapin direkapin_restore
```

Restore sungguhan memakai langkah yang sama ke database `direkapin`, setelah `api` dihentikan dan database lama dibuat ulang.
