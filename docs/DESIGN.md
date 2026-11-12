# Direkapin — Design guide

Semua layar Flutter wajib memakai token di file ini lewat `lib/core/theme/`.
Dilarang menulis warna hex, ukuran font, atau spacing langsung di widget.

## Karakter

**Hangat, rapi, dan cepat.** Seperti buku catatan pribadi yang enak dibuka setiap malam, bukan aplikasi bank.
- Angka uang adalah pusat perhatian: besar, tegas, mudah dipindai.
- Kalender terasa hidup: ikon, bintang, dan warna mood membuat bulan yang rajin dicatat terlihat "penuh".
- Sedikit dekorasi, banyak ruang. Tidak ada gradient, glassmorphism, atau bayangan tebal.

## Warna

| Token | Light | Dark | Dipakai untuk |
|---|---|---|---|
| `primary` | `#0F766E` | `#2DD4BF` | Tombol utama, FAB, tab aktif, tanggal terpilih |
| `onPrimary` | `#FFFFFF` | `#042F2E` | Teks/ikon di atas primary |
| `primaryContainer` | `#CCFBF1` | `#134E4A` | Chip terpilih, latar kartu saldo |
| `income` | `#15803D` | `#4ADE80` | Nominal pemasukan, ikon masuk di kalender |
| `expense` | `#DC2626` | `#F87171` | Nominal pengeluaran, ikon keluar di kalender, saldo negatif |
| `activity` | `#2563EB` | `#60A5FA` | Titik kegiatan, ikon kegiatan |
| `important` | `#F59E0B` | `#FBBF24` | Bintang kegiatan penting, badge streak |
| `background` | `#FAFAF9` | `#0C0A09` | Latar layar |
| `surface` | `#FFFFFF` | `#1C1917` | Kartu, sheet, dialog |
| `surfaceVariant` | `#F5F5F4` | `#292524` | Input, latar list item terpilih |
| `outline` | `#E7E5E4` | `#44403C` | Garis pemisah, border input |
| `textPrimary` | `#1C1917` | `#FAFAF9` | Teks utama |
| `textSecondary` | `#78716C` | `#A8A29E` | Label, keterangan, tanggal |
| `error` | `#B91C1C` | `#FCA5A5` | Pesan error form |

**Tema penuh (ENG-03, D-63).** Tabel di atas = tema Teal (bawaan) dan Gelap. User memilih 1 dari 7 tema di layar Tema (Profil). Tiap tema mengatur warna, radius kartu, bentuk tanggal, gaya penanda kalender, gaya tab aktif, dan maskot. Tema pastel memakai `surface` `#FFFFFF`, `error` `#B91C1C`, dan teks di atas `primary` = warna teks tema. Warna masuk/keluar pastel sudah digelapkan agar kontras >= 4.5:1. Di tema pastel `primary` terlalu terang untuk teks/garis, jadi aksen di atas latar (label tab aktif, kursor, border input fokus, progress, penanda terpilih, hari ini di kalender, bar anggaran normal) memakai `ink` (versi tua primary; di Teal dan Gelap `ink` = `primary`).

| Tema | primary | container | background | teks / sekunder | masuk / keluar | kegiatan / penting | teks tombol | radius kartu / tanggal | penanda | tab aktif | maskot |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Teal (bawaan) | `#0F766E` | `#CCFBF1` | `#FAFAF9` | `#1C1917` / `#78716C` | `#15803D` / `#DC2626` | `#2563EB` / `#F59E0B` | `#0F766E` | 16 / 12 | ikon | pil | Penyu |
| Kuning pastel | `#F5DE8C` | `#FBF3D5` | `#FFFBEF` | `#3B3218` / `#8A7E5C` | `#407E57` / `#AB5C4E` | `#7FA6C9` / `#D9A92E` | `#6B5410` | 22 / 8 | titik | pil | anak ayam |
| Biru langit | `#A7C7E7` | `#E3EEF8` | `#F5F9FD` | `#16263A` / `#6B7F96` | `#347E62` / `#B05555` | `#5B82CF` / `#E2AC45` | `#1E4A75` | 12 / 12 | batang | garis | paus |
| Lavender | `#C3B1E1` | `#EEE8F7` | `#FAF8FD` | `#2A2140` / `#7C7393` | `#3C7D66` / `#AE5472` | `#8776D2` / `#E2AC45` | `#4B3478` | 20 / 8 | titik | pil | kucing |
| Peach | `#F7C5B5` | `#FDECE6` | `#FFF8F5` | `#3A221B` / `#93766C` | `#407E57` / `#BA503D` | `#7FA6C9` / `#DFA13F` | `#7A3B28` | 24 / 12 | ikon | pil | hamster |
| Mint | `#A8D8C8` | `#E3F3EE` | `#F5FBF8` | `#15302A` / `#6A8A80` | `#287F5E` / `#B25656` | `#5E92CF` / `#E2AC45` | `#1F5C4A` | 14 / 6 | batang | garis | katak |
| Gelap | `#2DD4BF` | `#134E4A` | `#0C0A09` | `#FAFAF9` / `#A8A29E` | `#4ADE80` / `#F87171` | `#60A5FA` / `#FBBF24` | `#2DD4BF` | 16 / 12 | ikon | pil | burung hantu |

Tint mood sama di semua tema pastel: 😄 `#7BC79A` · 🙂 `#6FC1B5` · 😐 `#BDB7AE` · 😕 `#E8B96A` · 😢 `#8DB0E0`. Radius tanggal 12 = bulat. Warna kategori dan dompet tidak ikut tema.

Aturan:
- Warna masuk/keluar tema **hanya** untuk arah uang (masuk/keluar). Jangan dipakai untuk status lain.
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
- Elevasi: lihat bagian Frame (D-64). Bagian utama memakai frame luar (garis tebal + bayangan keras), elemen di dalamnya memakai frame dalam. FAB dan bottom sheet tetap memakai bayangan halus.
- Target sentuh minimal 48×48.

**Frame (D-64).** Kartu memakai dua jenis frame (`core/widgets/frame.dart`), garis 2 px warna `onSurface`:
- Frame luar `FrameCard`: bayangan keras tanpa blur, offset (4, 4) ke kanan-bawah (warna `onSurface`), radius `cardRadius` tema; menyisakan ruang 4 px di kanan/bawah supaya bayangan tidak terpotong. Dipakai untuk kartu, mis. kotak ringkasan Laporan dan kartu section.
- Frame dalam `FrameBox`: garis sama, tanpa bayangan, radius `cardRadius ÷ 2`. Dipakai untuk elemen di dalam kartu (chip, kotak kecil).
- Nilai `frameWidth` 2 dan `frameOffset` 4 ada di `AppStyle` (`app_themes.dart`); `cardRadius` per tema: Teal 16, Kuning pastel 22, Biru langit 12, Lavender 20, Peach 24, Mint 14, Gelap 16.

**Kotak ringkasan Laporan.** Tiga `FrameCard` sebaris: Pemasukan, Pengeluaran, Selisih. Latar tint per tema, teks selalu `onSurface` (kontras di atas latar muda hanya dijamin untuk `onSurface`, bukan warna masuk/keluar).

| Tema | Pemasukan (`incomeTint`) | Pengeluaran (`expenseTint`) | Selisih (`importantTint`) |
|---|---|---|---|
| Teal | `#CDEBD7` | `#F6D3CC` | `#F7E3A8` |
| Kuning pastel | `#CDE8CF` | `#F6D3C8` | `#F7E19A` |
| Biru langit | `#C9E8D6` | `#F4D0CF` | `#F6E3AC` |
| Lavender | `#CAE8DA` | `#F2CEDA` | `#F6E3AC` |
| Peach | `#CDE9D2` | `#F8CFC2` | `#F7E0A4` |
| Mint | `#C4E9D6` | `#F4D0CF` | `#F6E3AC` |
| Gelap | `#14301F` | `#3B1A18` | `#3A2E0C` |

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
| Sel kalender | Angka tanggal `labelSmall`; latar lingkaran tanggal diwarnai sesuai mood (`moodTints`, transparan 35%) (D-61); di bawahnya ikon 12 px: ↙ `income` (pemasukan), ↗ `expense` (pengeluaran), kalender `activity` (kegiatan) atau bintang `important` jika ada kegiatan penting; total keluar ringkas di bawahnya; hari ini = lingkaran outline `ink`. Penanda masuk/keluar mengikuti gaya tema: ikon (Teal, Peach, Gelap), titik kecil (Kuning, Lavender), atau batang kecil (Biru langit, Mint); kegiatan tetap ikon |
| Input nominal | Rata kanan, `displayAmount`, awalan "Rp", keyboard angka, pemisah ribuan otomatis saat mengetik |
| Pemilih kategori | Grid 4 kolom ikon + label `labelSmall`, terpilih = border `ink` 2 px |
| Toggle tipe | Segmented: Keluar · Masuk · Transfer (Keluar default) |
| FAB | `primary`, ikon `add_rounded`; tap → bottom sheet 2 pilihan: Transaksi, Kegiatan |
| Snackbar | Muncul setelah simpan/hapus. Hapus memakai dialog konfirmasi, tanpa undo |
| Skeleton | Kotak `surfaceVariant` dengan shimmer ringan, bentuk sama dengan konten asli |

## Layar Laporan

- Tab kapsul: Mingguan · Bulanan · Custom (Harian tidak ada lagi, D-64).
- Mingguan/Bulanan: panah geser periode. Custom: tanpa panah; rentang tanggal dipilih lewat pemilih (mulai–akhir), maksimal 366 hari, lebih dari itu snackbar "Rentang maksimal 366 hari". Rentang Custom tersimpan terpisah dan tetap saat pindah tab.
- Custom berisi sama dengan Bulanan (tiga kotak ringkasan, grafik garis harian, donut kategori Semua/Top 3) tanpa bagian Budget.

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

## Tema, maskot, dan gerak

**Transaksi berulang** (FIN-15, D-67): Profil > "Transaksi berulang" membuka daftar aturan; tiap baris = ikon + nama kategori, "Tiap tanggal {n} · {nama dompet}", dan nominal bertanda. Ketuk baris = form "Ubah aturan" (tombol "Hapus" di bilah atas); tombol "Tambah aturan" membuka form "Tambah aturan": pilih Keluar/Masuk, Nominal, Dompet, Kategori, "Tanggal tiap bulan" (bantuan: "Tanggal 29-31 jatuh ke hari terakhir di bulan pendek"), "Mulai bulan", "Berakhir bulan" ("Terus berjalan" bila kosong, ada "Hapus bulan berakhir"), "Catatan (opsional)", tombol "Simpan". Kosong: "Belum ada aturan. Tambah tagihan atau gaji yang rutin tiap bulan." Error bulan: "Bulan berakhir tidak boleh sebelum bulan mulai". Hapus: "Hapus aturan ini? Transaksi yang sudah tercatat tidak ikut terhapus."

**Kartu "Jatuh tempo" di Beranda** (`FrameCard`, di bawah bagian atas Beranda): judul "Jatuh tempo"; tiap kejadian = ikon kategori, nama kategori, "Jatuh tempo {tanggal panjang}", nominal bertanda (keluar negatif), lalu tombol "Lewati" dan "Catat" rata kanan. Satu kejadian per aturan (tertua). Kartu tersembunyi penuh saat kosong atau gagal dimuat (tanpa teks error). Tombol dikunci selama satu aksi berjalan.

**Sheet Catat**: judul "Catat {nama kategori}"; isian Nominal (terisi nominal aturan, wajib; "Nominal wajib diisi" bila kosong), tanggal transaksi, tombol "Simpan". Perubahan di sheet hanya berlaku untuk transaksi itu, aturan tidak berubah. Dialog "Lewati": "Lewati {kategori} untuk {Bulan Tahun}?" dengan tombol "Lewati" dan batal. Bila server membalas 409 (sudah dicatat di perangkat lain), kartu dimuat ulang tanpa menambah transaksi.

**Foto profil** (Profil, AUTH-05, D-65): avatar 40 dp di kotak sentuh 48 dp (label aksesibilitas "Ubah foto profil"); foto bila ada, selain itu (memuat, gagal, belum ada) inisial nama. Ketuk avatar membuka sheet bawah: "Ambil foto", "Pilih dari galeri", dan "Hapus foto" (hanya jika sudah ada foto). Saat unggah/hapus, avatar menampilkan indikator progres. Gagal = SnackBar berisi pesan server (koneksi gagal memakai teks "Server lagi nggak bisa dihubungi…"). Ketuk nama atau ikon pensil membuka dialog Ubah nama.

**Layar Tema** (Profil > Tema): daftar kartu 7 tema; tiap kartu menampilkan maskot, nama, dan contoh warna; frame border `onSurface`; terpilih ditandai ikon centang. Pilihan langsung berlaku dan disimpan di HP.

**Maskot** (hewan chubby digambar kode, ekspresi happy/neutral, tanpa aset): judul Beranda, `EmptyState` (neutral), kartu di layar Tema, dan baris Tema di Profil.

**Gerak**
- Durasi 200 ms, kurva `easeOutCubic`.
- Pindah tab bawah: konten bergeser horizontal sesuai arah tab (250 ms, `easeOutCubic`); state dan posisi scroll tab terjaga, fokus dilepas dari tab yang tersembunyi.
- Layar dalam (detail, form, foto) masuk dari kanan. Splash, login, dan Beranda juga bergeser masuk.
- Reduce-motion di HP mematikan semua animasi geser.
- Hanya animasikan yang memberi arti: angka saldo berubah, titik kalender muncul, sheet naik.
- Maskot ngintip: maskot 32 dp (`Spacing.xxl`, pose `peek`) melongok dari tepi atas tab bawah yang aktif; berpindah mengikuti tab selama 250 ms (`easeOutCubic`). Dekoratif: dibungkus `IgnorePointer` dan `ExcludeSemantics`, jadi tap tembus dan tidak dibaca screen reader. Reduce-motion: pindah instan.
