# Widget layar utama "Hari ini" (ENG-05) — design

Status: draft, menunggu persetujuan owner (dependency baru `home_widget`, kode native Android).

## Kebutuhan owner (2026-11-17)

- Widget Android di layar utama sebagai **pengingat** yang menampilkan **Keluar** dan **Masuk hari ini**.
- Ukuran bisa diubah; isi menyesuaikan.
- Tombol **+** langsung ke form Catat (mode Keluar). Tap bagian lain = buka aplikasi (Beranda).

## Data

- Sumber: `dashboard` yang sudah dimuat app — `last7Days` titik terakhir (`income`, `expense`) dan `today.hasEntry`, `today.date`.
- Ditulis ke penyimpanan widget lewat `home_widget` setiap `dashboardProvider` punya data baru (titik yang sama dengan sinkron reminder di `AppShell`): `date` (`YYYY-MM-DD`), `expense`, `income`, `hasEntry` (format Rupiah dibuat di Dart, widget hanya menampilkan teks).
- Widget **tidak** mengambil data sendiri. Jika `date` ≠ hari ini (app belum dibuka hari ini), widget menampilkan `Rp0` untuk keduanya dan teks pengingat `Belum dicatat hari ini`.
- Logout → data widget dikosongkan; widget menampilkan `Masuk dulu di Direkapin`.
- Saldo **tidak** ditampilkan (D-59: saldo selalu tersembunyi di luar ketukan ikon mata).

## Tampilan (neubrutalism, RemoteViews)

- Latar `surface`, garis 2 dp tinta, sudut 16 dp; warna terang/gelap mengikuti mode sistem (`values-night`), tidak mengikuti 7 tema app.
- Isi: judul kecil `Hari ini`, baris `Keluar −Rp45.000` (merah tema bawaan) dan `Masuk +Rp0` (hijau), teks status (`Belum dicatat hari ini` / `Sudah dicatat`), tombol bulat **+**.
- Ukuran: default 4×1; bisa diperkecil sampai 2×1 (lebar < 180 dp → baris Masuk disembunyikan, hanya Keluar + tombol +), diperbesar sampai 4×2.

## Navigasi

- **+** → URI `direkapin://catat` → app membuka `Routes.transactionForm` (di atas Beranda). Belum login → layar Login seperti biasa.
- Area lain → membuka aplikasi.

## Di luar cakupan

Widget saldo, widget kalender, tema widget mengikuti 7 tema app, widget yang memuat data sendiri dari server, iOS.
