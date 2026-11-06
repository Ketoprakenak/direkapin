# Mobile (Flutter) — konvensi

Baca juga `../CLAUDE.md`, `../docs/DESIGN.md` (wajib untuk semua UI), dan `../docs/openapi.yaml`.

## Struktur

```
mobile/lib/
├── main.dart
├── app.dart                    # MaterialApp.router + tema + locale id_ID
├── core/
│   ├── api/
│   │   ├── api_client.dart     # Dio, baseUrl dari --dart-define=API_URL
│   │   ├── auth_interceptor.dart  # pasang token, auto refresh saat 401, logout jika refresh gagal
│   │   └── api_error.dart      # parse format Error → ApiException(code, message, details)
│   ├── auth/                   # token storage (flutter_secure_storage), session provider
│   ├── router/router.dart      # go_router + redirect berdasarkan sesi
│   ├── theme/                  # tokens.dart (warna, spacing, radius), app_theme.dart, text_styles.dart
│   ├── format/                 # money.dart (Rp25.000, 25rb), dates.dart (id_ID)
│   ├── media/photo_service.dart   # pilih foto + kompres otomatis
│   ├── notifications/          # jadwal notifikasi lokal: reminder harian + arsip
│   ├── update/app_update.dart  # cek /version, buka link update
│   ├── icons.dart              # map nama ikon string → IconData
│   └── widgets/                # komponen bersama: AmountText, EmptyState, ErrorState, Skeleton, ...
└── features/
    └── <fitur>/                # auth, dashboard, calendar, day, transaction, activity,
        ├── data/               # wallet, category, report, archive, settings
        │   ├── <fitur>_api.dart        # panggilan endpoint
        │   ├── <fitur>_models.dart     # freezed + json_serializable, field = openapi.yaml
        │   └── <fitur>_repository.dart
        ├── providers/          # Riverpod (riverpod_generator)
        └── presentation/
            ├── <layar>_screen.dart
            └── widgets/
```

## Pola wajib

- **State**: Riverpod dengan `riverpod_generator` (`@riverpod`). Data server = `AsyncNotifier` / `FutureProvider`. Setelah create/update/delete, `ref.invalidate` provider terkait (dashboard, calendar, day, reports) — tidak ada state global manual.
- **Layar** selalu menangani `AsyncValue`: `loading` → skeleton, `error` → `ErrorState` dengan tombol "Coba lagi", data kosong → `EmptyState` dengan teks dari `DESIGN.md`.
- **Model** mengikuti nama field `openapi.yaml` persis (camelCase). Nominal = `int`. Timestamp = `DateTime` UTC, ditampilkan `.toLocal()`. Tanggal tanpa jam = `String` `YYYY-MM-DD` atau helper `LocalDate`, bukan `DateTime` tengah malam.
- **Tidak ada warna, ukuran font, atau spacing hardcoded** di widget; selalu dari `core/theme/tokens.dart` / `Theme.of(context)`.
- **Format uang/tanggal** hanya lewat `core/format/`.
- **Navigasi** hanya lewat `go_router` (nama route konstan). Bottom nav 4 tab memakai `StatefulShellRoute`.
- **Pesan error ke user** = `ApiException.message` dari server; kalau koneksi gagal → teks "Server lagi nggak bisa dihubungi…" dari `DESIGN.md`.

## Foto (FIN-13) — tidak boleh ada kompres manual

`core/media/photo_service.dart` adalah satu-satunya jalan mengambil foto:
1. `image_picker` (kamera satu foto, galeri boleh pilih banyak sesuai sisa slot) dengan `maxWidth: 1600`, `imageQuality: 85`.
2. `flutter_image_compress` → JPEG, `minWidth/minHeight` sesuai rasio, lebar maks. 1600, quality 80; jika hasil > 400 KB ulangi dengan quality 70, lalu 60.
3. HEIC dikonversi ke JPEG di langkah yang sama; metadata EXIF lokasi dibuang.
4. Kembalikan file hasil kompres + ukuran; UI tidak pernah melihat file asli.

Upload dilakukan **setelah** transaksi/kegiatan tersimpan. Upload gagal → item tetap tersimpan, foto ditandai gagal dengan tombol "Coba lagi".

## Notifikasi (D-21) — lokal saja, tanpa push server

- **Reminder harian:** jadwalkan 30 hari ke depan pada `reminderTime`. Pasang ulang saat aplikasi dibuka, catatan disimpan, atau jam diubah; hari ini dilewati jika `today.hasEntry` true. `AppShell` memicunya setiap `dashboardProvider` atau `meProvider` punya data baru.
- **Arsip:** saat aplikasi dibuka, cek `/archives`. Arsip `READY` yang baru terlihat → notifikasi langsung + jadwalkan pengingat `createdAt` + 7 dan + 25 hari; batalkan setelah download.
- **Tanggal 1:** jadwalkan pengingat umum pukul 09.00 untuk 3 bulan ke depan, karena HP tidak tahu ada arsip baru sebelum aplikasi dibuka.

## Test

- `flutter_test`: unit test `core/format`, `photo_service` (ukuran hasil), parsing model dari contoh JSON `openapi.yaml`.
- Widget test: form transaksi (validasi nominal & kategori), sel kalender (titik & bintang), state kosong/error.
- Uji manual di HP asli via APK release untuk kamera, notifikasi, dan jaringan lemah.

## Perintah

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run --dart-define=API_URL=http://<ip-laptop-dev>:3000   # backend dari npm run dev; HTTP hanya untuk build debug
flutter build apk --release --dart-define=API_URL=https://api.appdirekapin.my.id
```
