# Keputusan teknis (ADR ringkas)

Keputusan di sini sudah final. Jangan diubah atau "diperbaiki" tanpa persetujuan owner.
Kalau ada alasan kuat untuk berubah, tulis usulan di bawah bagian "Usulan" dan tunggu persetujuan.

| # | Keputusan | Alasan | Alternatif yang ditolak |
|---|---|---|---|
| D-01 | Backend custom Node.js + Fastify + Prisma | Tidak terikat platform, ringan di RAM mini PC | Supabase self-hosted (berat, banyak container) |
| D-02 | Node.js 22 LTS | Node 20 sudah melewati masa dukungan (EOL April 2026) | Node 20 |
| D-03 | PostgreSQL 16 | Relasional, agregat laporan kuat | MySQL, SQLite |
| D-04 | Hosting di mini PC rumah + Cloudflare Tunnel | Gratis, tembus CGNAT, HTTPS otomatis, tanpa buka port | VPS, port forwarding |
| D-05 | Distribusi APK lewat GitHub Releases | Tidak perlu Play Store | Play Store |
| D-06 | Nominal disimpan `BigInt` Rupiah, dikirim sebagai integer JSON | Tidak ada error pembulatan; nominal maks. Rp999.999.999 aman di number JS/Dart | Decimal, float |
| D-07 | Saldo dompet dihitung, tidak disimpan | Tidak pernah selisih dengan transaksi | Kolom saldo yang di-update |
| D-08 | Waktu disimpan UTC (`timestamptz`), zona waktu per user | Konsisten lintas device | Simpan waktu lokal |
| D-09 | Kategori bawaan **disalin per user** saat registrasi (`isDefault = true`) | Setiap user bisa menyembunyikan/mengubah urutan tanpa memengaruhi user lain | Kategori global dengan `userId = null` |
| D-10 | Attachment pakai FK nullable `transactionId` / `activityId` (tepat satu terisi) | Integritas data + cascade delete | Polimorfik `ownerType` + `ownerId` tanpa FK |
| D-11 | Kompresi foto di HP (`flutter_image_compress`), `sharp` di server hanya pengaman + thumbnail | Hemat bandwidth dan CPU Celeron | Kompres di server |
| D-12 | Auth: JWT access 15 menit + refresh token 30 hari (di-hash di DB, rotasi tiap refresh) | Stateless, multi-device, bisa dicabut | Session cookie |
| D-13 | Registrasi wajib kode undangan | API terbuka ke internet, user terbatas | Registrasi bebas |
| D-14 | Tanpa offline mode & realtime sync di MVP | Data di-refresh saat layar dibuka / pull-to-refresh | Local DB + sync |
| D-15 | Arsip foto bulanan (ZIP M-2), thumbnail tetap di server | Storage tetap lega tanpa merusak tampilan | Hapus foto langsung |
| D-16 | Nama tabel snake_case jamak (`@@map`), nama kolom camelCase (default Prisma) | Konsisten dengan kode TS | Kolom snake_case |
| D-17 | Akses data dari user lain → 404 | ID data orang lain tidak bisa ditebak keberadaannya | 403 |
| D-18 | Prisma dikunci di 6.x (`prisma` dan `@prisma/client` versi sama) | `schema.prisma` tetap apa adanya, tanpa dependency tambahan | Prisma 7+ (wajib `prisma.config.ts` + `@prisma/adapter-pg`) |
| D-19 | Dev dan test memakai PostgreSQL 16 yang ter-install di laptop, API dev jalan di laptop (`npm run dev`). Docker hanya di mini PC, dan `docker-compose.yml` tidak mem-publish port apa pun | Data palsu dan reset test terpisah total dari data asli; tidak perlu Docker di laptop. Batasannya: `Dockerfile` dan compose baru teruji saat pertama jalan di mini PC | Database dev di mini PC (port harus dibuka, satu server dengan data asli); Docker Desktop di laptop |
| D-20 | Template kategori bawaan = konstanta di `backend/src/lib/default-categories.ts`, disalin saat registrasi. Seed hanya membuat kode undangan | `Category.userId` wajib, sesuai D-09 | Tabel template terpisah |
| D-21 | Notifikasi hanya lokal (`flutter_local_notifications`), tanpa push server | Tidak perlu Firebase. Batasannya: HP baru tahu status terbaru saat aplikasi dibuka | FCM |
| D-22 | Status `DOWNLOADED` diset setelah stream ZIP selesai utuh, lalu foto asli dihapus. ZIP tetap bisa di-download ulang sampai `expiresAt` | Foto tidak hilang kalau file di HP gagal tersimpan | Tandai saat request masuk; endpoint konfirmasi dari HP |
| D-23 | Job arsip jalan harian 02:00 dan idempoten: buat arsip M-2 yang belum ada atau `FAILED`, lalu bereskan yang kedaluwarsa. Bulan foto = `Attachment.createdAt` di zona waktu user. Bulan tanpa foto dilewati | Otomatis mengejar kalau job gagal atau mini PC mati; foto yang diupload belakangan tidak jatuh ke bulan yang sudah diarsip | Job hanya tanggal 1; bulan dari tanggal transaksi/kegiatan |

| D-24 | Rate limit login menghitung semua percobaan, 10 per 15 menit per IP, memakai header `CF-Connecting-IP` | Login jarang dengan sesi 30 hari. Tanpa header itu semua user terbaca satu IP (`cloudflared`). Aman karena API hanya bisa dicapai lewat tunnel | Hanya menghitung yang gagal; memakai IP koneksi |
| D-25 | Refresh token = 32 byte acak, disimpan sebagai SHA-256. `/auth/logout` tidak butuh access token | Dicek ke DB, jadi tanda tangan JWT tidak perlu. Access token bisa sudah kedaluwarsa saat logout | Refresh token JWT + `JWT_REFRESH_SECRET`; logout wajib access token |
| D-26 | Email disimpan huruf kecil | `Desta@x.com` dan `desta@x.com` adalah satu akun | Case-sensitive |

| D-27 | Dompet atau kategori di body yang bukan milik user dibalas 400 (`Pilih dompet` / `Pilih kategori`), sama dengan ID yang tidak ada. ID di URL tetap 404 | Keberadaan data orang lain tidak terbongkar, dan user dapat pesan form yang jelas | 404 untuk semua |
| D-28 | Total saldo Beranda tidak menghitung dompet arsip | Total cocok dengan kartu dompet yang terlihat. Batasannya: sisa uang di dompet arsip tidak terlihat di total | Menghitung semua dompet |
| D-29 | Transaksi dan transfer di dompet arsip boleh diedit selama dompetnya tidak diganti; dompet tujuan baru harus aktif | Data lama tetap bisa dikoreksi | Melarang semua edit |
| D-30 | Streak belum putus selama hari ini belum lewat. Transfer tidak dihitung | Streak tidak terlihat 0 setiap pagi | Putus jika hari ini kosong |
| D-31 | Dompet terpilih di form = dompet transaksi terakhir, atau dompet aktif pertama | Tanpa kolom atau penyimpanan baru | Simpan pilihan di HP |

| D-32 | Hapus transaksi/transfer cukup dialog konfirmasi, tanpa undo | US-05 minta konfirmasi; undo butuh penundaan hapus | Konfirmasi + undo 4 detik |
| D-33 | Transfer tidak punya titik kalender, dan tanggal yang hanya berisi transfer tidak masuk `/calendar`. Tetap tampil di Halaman Hari | CAL-01 hanya menyebut pemasukan, pengeluaran, kegiatan | Titik khusus transfer |
| D-34 | Saat edit, kategori tersembunyi dan dompet arsip yang sedang dipakai tetap muncul di pilihan | Form tidak kehilangan nilai aslinya (D-29) | Memaksa memilih ulang |
| D-35 | Foto ditampilkan lewat `dio` + cache memori, bukan `cached_network_image` | Token ikut terpasang dan di-refresh saat 401 | `cached_network_image` |
| D-36 | PNG diubah ke JPEG di server | Kontrak `GET /attachments/{id}` hanya JPEG dan WebP | Simpan PNG apa adanya |
| D-37 | Upload gagal: transaksi tetap tersimpan, form terbuka dengan "Coba lagi" dan "Lewati"; antrean tidak disimpan | Sederhana; data uang tidak pernah bergantung pada foto | Antrean upload di latar belakang |
| D-38 | Upload berurutan; batas foto dicek tanpa kunci di server | Maks. 4 user dan aplikasi tidak upload paralel | Kunci baris per transaksi |
| D-39 | Endpoint foto kegiatan (batas 5) ikut dibuat di Slice 4, tampilannya di Slice 5 | Satu endpoint yang sama di kontrak | Tunda sampai Slice 5 |
| D-40 | Simpan foto ke galeri lewat `MethodChannel` + MediaStore di `MainActivity.kt` | Tanpa dependency baru, dan Slice 8 bisa memakai jalur yang sama untuk ZIP | Paket galeri pihak ketiga |

## Dependency yang disetujui

**Backend:** `fastify`, `@fastify/multipart`, `@fastify/rate-limit`, `@fastify/cors`, `@fastify/sensible`, `fastify-type-provider-zod`, `zod`, `@prisma/client`, `prisma`, `bcrypt`, `jsonwebtoken`, `sharp`, `archiver`, `node-cron`, `pino-pretty` (dev), `vitest`, `supertest`, `eslint`, `typescript-eslint`, `typescript`, `tsx`, `@types/node`, `@types/bcrypt`, `@types/jsonwebtoken`.

**Mobile:** `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`, `go_router`, `dio`, `flutter_secure_storage`, `freezed`, `freezed_annotation`, `json_annotation`, `json_serializable`, `build_runner`, `intl`, `table_calendar`, `fl_chart`, `image_picker`, `flutter_image_compress`, `flutter_local_notifications`, `timezone`, `cached_network_image`, `path_provider`, `permission_handler`, `google_fonts`, `package_info_plus`, `flutter_localizations` (SDK), `flutter_lints` (dev).

Dependency lain → minta izin dulu.

## Usulan (belum disetujui)

_(kosong)_
