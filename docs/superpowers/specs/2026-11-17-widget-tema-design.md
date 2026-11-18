# Widget "Hari ini": tema + gambar penyemangat (ENG-05 lanjutan) — design

Status: draft, menunggu persetujuan owner. Menambah `docs/superpowers/specs/2026-11-17-widget-hari-ini-design.md` (dikerjakan lebih dulu).

## Kebutuhan owner (2026-11-17)

- Widget **ikut tema app** (7 tema), bukan cuma terang/gelap.
- Ada gambar kecil di widget:
  - **Bawaan:** maskot tema masing-masing dalam pose **berdiri full badan** (kaki/tangan/ekor kelihatan), ukuran kecil — bukan bulatan "koin" seperti pose `full` sekarang.
  - **Pilihan:** **foto sendiri dari galeri** sebagai penyemangat.

## Tema

- App menulis warna tema aktif ke penyimpanan widget setiap tema berganti dan setiap sinkron dashboard: `surface`, `ink` (garis), `text`, `textSecondary`, `income`, `expense` (ARGB int), plus `radius` (`cardRadius` tema).
- Kotlin memakai **7 drawable latar** statis (`today_widget_bg_<tema>.xml`, stroke 2 dp warna tinta, sudut = `cardRadius` tema, warna dari tabel DESIGN.md), dipilih lewat kunci `theme` (`teal`, `kuning`, `biru`, `lavender`, `peach`, `mint`, `gelap`); warna teks lewat `setTextColor`. Mode gelap sistem tidak lagi dipakai — yang menentukan tema app.

## Gambar = latar widget (revisi owner 2026-11-17)

- Gambar mengisi **seluruh latar widget** (bukan slot kecil), di semua ukuran termasuk 2×1. Teks dan tombol + tetap warna penuh di atasnya.
- Latar **dipudarkan**: saturasi 35% (dibakar di Dart saat membuat file gambar) + lapisan `surface` tema 55% di Kotlin (`setBackgroundColor`) supaya angka tetap kebaca.
- **Maskot (bawaan):** pose baru `MascotPose.wave` di `Mascot` (Flutter) — **luwes, bukan berdiri tegak**: badan miring, satu sirip/sayap/kaki melambai, kaki tidak simetris, pipi merah (mockup `widget_latar_maskot_pudar_mockup`: penyu melambai, anak ayam loncat, kucing duduk angkat kaki, burung hantu di dahan). Ekspresi `happy` bila sudah mencatat hari ini, `neutral` bila belum. Maskot diletakkan di kanan-bawah, sebagian terpotong tepi. Dirender ke PNG 640×320 px oleh `HomeWidget.renderFlutterWidget`.
- **Foto sendiri:** Profil > **Gambar widget** → pilih `Maskot tema` / `Foto dari galeri`. Foto dipotong tengah rasio 2:1, diperkecil ke **640×320 px JPEG** kualitas 85, saturasi 35%, disimpan di folder dokumen app. **Tidak diupload ke server** dan tidak ikut backup.
- Widget menampilkan gambar `centerCrop`; sudut membulat lewat `clipToOutline` (Android 12+). Android 8–11: sudut gambar kotak di dalam bingkai (diterima).
- Ganti tema → maskot dirender ulang. Hapus foto (pilih Maskot tema) → file dihapus.

## Di luar cakupan

Animasi maskot di widget, beberapa foto bergiliran, foto ikut tersinkron antar-HP, widget iOS.
