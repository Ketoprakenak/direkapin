# Direkapin — Design guide

Semua layar Flutter wajib memakai token di file ini lewat `lib/core/theme/`.
Dilarang menulis warna hex, ukuran font, atau spacing langsung di widget.

## Karakter

**Hangat, rapi, dan cepat.** Seperti buku catatan pribadi yang enak dibuka setiap malam, bukan aplikasi bank.
- Angka uang adalah pusat perhatian: besar, tegas, mudah dipindai.
- Kalender terasa hidup: titik warna dan bintang membuat bulan yang rajin dicatat terlihat "penuh".
- Sedikit dekorasi, banyak ruang. Tidak ada gradient, glassmorphism, atau bayangan tebal.

## Warna

| Token | Light | Dark | Dipakai untuk |
|---|---|---|---|
| `primary` | `#0F766E` | `#2DD4BF` | Tombol utama, FAB, tab aktif, tanggal terpilih |
| `onPrimary` | `#FFFFFF` | `#042F2E` | Teks/ikon di atas primary |
| `primaryContainer` | `#CCFBF1` | `#134E4A` | Chip terpilih, latar kartu saldo |
| `income` | `#15803D` | `#4ADE80` | Nominal pemasukan, titik hijau kalender |
| `expense` | `#DC2626` | `#F87171` | Nominal pengeluaran, titik merah kalender, saldo negatif |
| `activity` | `#2563EB` | `#60A5FA` | Titik kegiatan, ikon kegiatan |
| `important` | `#F59E0B` | `#FBBF24` | Bintang kegiatan penting, badge streak |
| `background` | `#FAFAF9` | `#0C0A09` | Latar layar |
| `surface` | `#FFFFFF` | `#1C1917` | Kartu, sheet, dialog |
| `surfaceVariant` | `#F5F5F4` | `#292524` | Input, latar list item terpilih |
| `outline` | `#E7E5E4` | `#44403C` | Garis pemisah, border input |
| `textPrimary` | `#1C1917` | `#FAFAF9` | Teks utama |
| `textSecondary` | `#78716C` | `#A8A29E` | Label, keterangan, tanggal |
| `error` | `#B91C1C` | `#FCA5A5` | Pesan error form |

Aturan:
- Hijau/merah **hanya** untuk arah uang (masuk/keluar). Jangan dipakai untuk status lain.
- Warna kategori dan dompet diambil dari palet kategori di bawah, bukan warna bebas. Satu pengecualian: kategori bawaan "Lainnya" pengeluaran memakai abu-abu `#78716C`.

**Palet kategori/dompet (8 warna):** `#EF4444` `#F97316` `#EAB308` `#22C55E` `#14B8A6` `#3B82F6` `#8B5CF6` `#EC4899`

## Tipografi

Font: **Plus Jakarta Sans** (via `google_fonts`), angka memakai `fontFeatures: [FontFeature.tabularFigures()]`.

| Token | Ukuran / tinggi baris | Berat | Dipakai untuk |
|---|---|---|---|
| `displayAmount` | 32 / 40 | 700 | Total saldo di Beranda, nominal di form |
| `titleLarge` | 22 / 28 | 700 | Judul layar |
| `titleMedium` | 17 / 24 | 600 | Judul kartu, nama dompet |
| `bodyLarge` | 16 / 24 | 400 | Isi utama, nama transaksi |
| `bodyMedium` | 14 / 20 | 400 | Keterangan, catatan |
| `labelLarge` | 14 / 20 | 600 | Tombol, tab |
| `labelSmall` | 12 / 16 | 500 | Label kecil, tanggal di kalender, caption |
| `amount` | 16 / 24 | 600 | Nominal di list (tabular) |

## Spacing, radius, elevasi

- Spacing (kelipatan 4): `xs 4` · `sm 8` · `md 12` · `lg 16` · `xl 24` · `xxl 32`
- Padding layar: `lg 16` kiri-kanan. Jarak antar kartu: `md 12`. Jarak antar section: `xl 24`.
- Radius: `sm 8` (chip, input) · `md 12` (list item, tombol) · `lg 16` (kartu) · `xl 24` (bottom sheet) · `full` (FAB, avatar, titik kalender)
- Elevasi: kartu datar dengan border `outline` 1 px. Hanya FAB dan bottom sheet yang memakai bayangan halus.
- Target sentuh minimal 48×48.

## Ikon

Material Symbols Rounded (bawaan Flutter `Icons.*_rounded`). Satu gaya saja di seluruh aplikasi.

**Kategori bawaan (seed):**

| Kategori | Tipe | Ikon | Warna |
|---|---|---|---|
| Makan | EXPENSE | `restaurant_rounded` | `#F97316` |
| Transport | EXPENSE | `directions_bus_rounded` | `#3B82F6` |
| Kuliah | EXPENSE | `school_rounded` | `#8B5CF6` |
| Hiburan | EXPENSE | `sports_esports_rounded` | `#EC4899` |
| Belanja | EXPENSE | `shopping_bag_rounded` | `#EAB308` |
| Tagihan | EXPENSE | `receipt_long_rounded` | `#EF4444` |
| Lainnya | EXPENSE | `more_horiz_rounded` | `#78716C` |
| Gaji / Uang saku | INCOME | `payments_rounded` | `#22C55E` |
| Lainnya | INCOME | `more_horiz_rounded` | `#14B8A6` |

**Dompet:** CASH `account_balance_wallet_rounded` · BANK `account_balance_rounded` · EWALLET `phone_iphone_rounded`

Dompet "Cash" yang dibuat saat registrasi memakai warna `#14B8A6`.

Nilai `icon` di database = nama ikon tanpa `Icons.` (contoh `restaurant_rounded`); mobile memetakannya lewat satu map di `lib/core/icons.dart`.

## Komponen inti

| Komponen | Spesifikasi |
|---|---|
| Kartu saldo | `primaryContainer`, radius `lg`, total saldo `displayAmount`, di bawahnya baris masuk/keluar bulan ini |
| Kartu dompet | Lebar 140, scroll horizontal, ikon dalam lingkaran warna dompet 15% opacity, nama + saldo |
| List item transaksi | Tinggi 64; kiri ikon kategori (lingkaran 40, warna kategori 15%), tengah nama kategori + catatan/dompet (`bodyMedium` secondary), kanan nominal `amount` (+hijau / −merah) dan thumbnail 32 jika ada foto |
| List item kegiatan | Garis kiri 3 px warna `activity`; judul, jam (atau "Seharian"); bintang `important` jika penting |
| Sel kalender | Angka tanggal `labelSmall`; maks. 3 titik 6 px (hijau, merah, biru) di bawah angka; bintang kecil jika ada kegiatan penting; hari ini = lingkaran outline `primary`; terpilih = isi `primary` |
| Input nominal | Rata kanan, `displayAmount`, awalan "Rp", keyboard angka, pemisah ribuan otomatis saat mengetik |
| Pemilih kategori | Grid 4 kolom ikon + label `labelSmall`, terpilih = border `primary` 2 px |
| Toggle tipe | Segmented: Keluar · Masuk · Transfer (Keluar default) |
| FAB | `primary`, ikon `add_rounded`; tap → bottom sheet 2 pilihan: Transaksi, Kegiatan |
| Snackbar | Muncul setelah simpan/hapus. Hapus memakai dialog konfirmasi, tanpa undo |
| Skeleton | Kotak `surfaceVariant` dengan shimmer ringan, bentuk sama dengan konten asli |

## Format

- Uang: `Rp25.000` (titik ribuan, tanpa desimal, tanpa spasi). Pengeluaran di list: `−Rp25.000` merah; pemasukan `+Rp25.000` hijau. Saldo negatif: `−Rp25.000` merah.
- Ringkas di grafik/kalender: `25rb`, `1,2jt`.
- Tanggal panjang: `Rabu, 4 November 2026` · pendek: `4 Nov` · bulan: `November 2026` (locale `id_ID`).
- Jam: `21.00` (format Indonesia, 24 jam).

## Bahasa UI

- Bahasa Indonesia santai-sopan, sapa user dengan **"kamu"**.
- Kalimat pendek dan aktif. Tombol pakai kata kerja: "Simpan", "Tambah transaksi", "Download arsip".
- Tanpa emoji di teks UI (kecuali pilihan mood).

Contoh:
| Situasi | Teks |
|---|---|
| Halaman Hari kosong | "Belum ada catatan hari ini. Mulai dari pengeluaran pertamamu." |
| Kalender bulan kosong | "Bulan ini masih kosong. Yuk, catat yang pertama." |
| Streak | "7 hari berturut-turut mencatat" |
| Server offline | "Server lagi nggak bisa dihubungi. Coba lagi sebentar." |
| Upload foto gagal | "Foto gagal diupload. Transaksi tetap tersimpan." + tombol "Coba lagi" |
| Notifikasi harian | "Hari ini udah dicatat belum? Cuma butuh 15 detik." |
| Versi baru | "Versi baru 1.0.0 sudah ada." + tombol "Update" dan "Nanti" |
| Konfirmasi hapus | "Hapus transaksi ini? Foto struknya juga ikut terhapus." |

## Gerak

- Durasi 200 ms, kurva `easeOutCubic`. Pindah tab tanpa animasi geser.
- Hanya animasikan yang memberi arti: angka saldo berubah, titik kalender muncul, sheet naik.
