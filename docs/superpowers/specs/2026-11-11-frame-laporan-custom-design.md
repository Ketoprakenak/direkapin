# Frame kartu + Laporan Custom + maskot ngintip — desain

Tanggal: 2026-11-11 · Ref: ENG-03 (tema), laporan (PRD bagian laporan) · Lanjutan dari `2026-11-11-tema-penuh-design.md`

## Maksud

Owner merasa tampilan sekarang "nyatu semua": kartu putih di atas latar hampir putih dengan garis tepi tipis
sewarna latar. Owner ingin gaya "frame" seperti referensi (gaya neubrutalism): garis tepi tebal gelap dan bayangan
keras yang menonjol, supaya tiap bagian terlihat berdiri. Elemen di dalam kartu (frame di dalam frame) memakai
garis yang sama tapi tanpa bayangan, supaya ada tingkatan dan tidak monoton.

Di Laporan, owner menyukai susunan referensi: pilihan periode berbentuk kapsul dan ringkasan berupa kotak warna.
Laporan Harian kurang berguna; gantinya laporan **Custom** (dari tanggal X sampai tanggal Y).

Maskot sejauh ini hanya muncul di samping sapaan Beranda dan terasa kurang terpakai. Owner ingin maskot "ngintip"
dari atas tab aktif di menu bawah, seolah melihat ke menu itu.

## Tujuan

1. **Frame luar** pada setiap bagian utama di semua menu: garis tepi tebal + bayangan keras ke kanan bawah.
2. **Frame dalam** pada elemen di dalam bagian: garis tepi tebal yang sama, tanpa bayangan.
3. **Laporan** bergaya referensi: tab kapsul **Mingguan / Bulanan / Custom** (urutan ini), tab aktif berupa blok
   gelap penuh; ringkasan berupa 3 kotak warna berframe luar (Pemasukan, Pengeluaran, Selisih).
4. **Laporan Custom**: user memilih tanggal mulai dan akhir; isinya persis sama dengan Bulanan.
5. Tab **Harian** dihapus dari app.
6. **Maskot ngintip** dari tepi atas tab aktif di menu bawah, pindah dengan halus saat tab berganti.

## Bukan tujuan

- Arus Kas / Kekayaan & Portofolio, Kuartal, Tahun, tombol Export, ikon pengaturan dari referensi.
- Font tulisan tangan atau font per tema.
- Frame pada form isian (transaksi, kegiatan, transfer, dompet, kategori), layar login/daftar, dialog, dan
  menu bawah itu sendiri.
- Menghapus endpoint `/reports/daily` di backend (dibiarkan; app tidak memakainya lagi).
- Maskot realistis / PNG (menyusul; titik tukarnya tetap widget `Mascot`).
- Mengubah `schema.prisma`.

## Anti-tujuan (gagal walau "jalan")

- Garis atau bayangan frame tidak terlihat di salah satu tema (terutama Gelap).
- Bayangan frame terpotong oleh tepi layar atau oleh bagian di sebelahnya.
- Maskot menutupi ikon/label tab atau tombol yang bisa ditekan, atau menghalangi tap.
- Laporan Custom menampilkan data user lain, atau rentang besar membuat server lambat.
- Pindah tab kehilangan state/scroll (container cabang yang sudah ada harus tetap dipakai).

## Batasan

- Tanpa dependency baru. `showDateRangePicker` bawaan Flutter untuk memilih rentang.
- Kontrak: `docs/openapi.yaml` **ditambah** endpoint `GET /reports/range` dan nilai `range` pada `period.type`.
  Owner menyetujui perubahan kontrak ini dengan menyetujui dokumen ini.
- Widget tidak hardcode warna/ukuran; ketebalan garis, offset bayangan, dan warnanya datang dari tema.
- Aturan data tetap: query difilter `userId`; dompet milik user lain → 404; nominal integer; tanggal `YYYY-MM-DD`;
  zona waktu user dipakai untuk batas hari; transfer tidak masuk laporan.

## Pendekatan

**Frame**
1. **Dipilih — dua widget bersama** di `core/widgets` (frame luar dan frame dalam), digambar dengan
   `BoxDecoration` (border + `BoxShadow` dengan `blurRadius: 0` dan offset). Tiap bagian layar dibungkus widget ini.
   Nilai frame (tebal garis, offset, warna) ditambahkan ke `AppStyle`/`AppColors` per tema.
2. Ditolak — hanya mengatur `CardTheme`: `Card` memakai bayangan blur dari elevation, tidak bisa bayangan keras;
   dan sebagian besar bagian layar sekarang bukan `Card`, jadi tetap harus dibungkus satu per satu.

**Maskot ngintip**
1. **Dipilih — lapisan di atas menu bawah** di `AppShell`: `Stack` berisi `NavigationBar` dan maskot yang
   posisinya mengikuti index tab aktif (animasi geser). `NavigationBar` tidak diubah.
2. Ditolak — maskot dimasukkan ke ikon tab: terpotong oleh tinggi menu bawah dan ikut gaya indikator tab.

**Laporan Custom**
1. **Dipilih — endpoint baru `/reports/range`** yang memakai ulang fungsi periode yang sudah ada
   (`getTotals`, `getSeries`, `getByCategory`).
2. Ditolak — app memanggil laporan bulanan berkali-kali lalu menggabungkan: lambat, rumit, dan donut/total salah
   untuk rentang yang memotong bulan.

## Yang sudah diputuskan

### Frame

| | Frame luar | Frame dalam |
|---|---|---|
| Dipakai di | bagian utama tiap menu | elemen di dalam bagian |
| Garis | 2 px | 2 px |
| Bayangan | keras, tanpa blur, offset (4, 4) | tidak ada |
| Sudut | `cardRadius` tema | lebih kecil dari `cardRadius` (mis. setengahnya) |
| Isi | permukaan (`surface`) | permukaan / transparan |

- Warna garis dan bayangan = `onSurface` tema di semua tema (gelap di tema terang, terang di Gelap). Kontras garis
  terhadap latar dan permukaan ≥ 3:1 (dicek di unit test).
- Ruang bayangan: bagian berframe luar diberi jarak kanan/bawah ≥ offset supaya bayangan tidak terpotong.

Penerapan **frame luar**:
- Beranda: kartu saldo, ringkasan hari ini, grafik 7 hari, transaksi terakhir, streak/badge.
- Kalender: kotak grid bulan.
- Hari: daftar transaksi dan daftar kegiatan, catatan harian.
- Laporan: 3 kotak ringkasan, grafik harian, donut kategori.
- Budget: tiap kartu budget.
- Profil: tiap grup menu.
- Tema: tiap kartu pratinjau.

Penerapan **frame dalam**: chip 7/30/100 di badge streak, pilihan dompet di Laporan, chip Top 3/Semua,
pemilih bulan/minggu/rentang di Laporan.

### Laporan

- Tab kapsul berframe dalam: **Mingguan · Bulanan · Custom**. Tab aktif = blok penuh warna teks tema dengan teks
  warna permukaan (gelap di tema terang, terang di Gelap). Bawaan saat dibuka = Bulanan (seperti sekarang).
- Baris di bawah tab: pemilih periode berframe dalam, lalu pilihan dompet berframe dalam. Navigasi periode yang
  sekarang (panah kiri/kanan untuk minggu/bulan) **tetap**; hanya bentuknya yang diganti frame dalam. Di Custom,
  ketuk label rentang → pemilih rentang (tanpa panah).
- 3 kotak ringkasan sejajar, berframe luar, warna latar versi muda dari warna tema:
  Pemasukan = masuk, Pengeluaran = keluar, Selisih = penting. Teks di dalamnya tetap lolos kontras ≥ 4.5.
- Isi di bawahnya tetap: grafik garis pengeluaran per hari, donut kategori dengan toggle Top 3 / Semua.

### Laporan Custom

- Tab Custom pertama kali dibuka: rentang bawaan = 1 tanggal bulan ini sampai hari ini; ketuk pemilih rentang →
  `showDateRangePicker` (lokal id_ID). Batas pilih: maksimal 366 hari, tidak melewati hari ini.
- `GET /reports/range?from=YYYY-MM-DD&to=YYYY-MM-DD&wallet=<uuid?>` → bentuk respons sama dengan laporan lain,
  `period.type = "range"`, `start = from`, `end = to`.
- Validasi: `from`/`to` wajib format tanggal; `to < from` → 400 `VALIDATION_ERROR`; rentang > 366 hari
  (inklusif kedua ujung, yaitu `to − from > 365` hari) → 400; batas yang sama dipakai pemilih di HP;
  dompet milik user lain → 404.
- `series` per hari sepanjang rentang. Sumbu bawah grafik menampilkan label tanggal secukupnya (tidak tiap hari).
- `comparison`: periode sebelumnya dengan panjang sama tepat sebelum `from`; perilaku sama dengan Bulanan
  (`changePct` null bila pengeluaran sebelumnya 0). Query memakai ulang `getSeries`/`getByCategory` apa adanya
  (maks. 366 titik, 4 user — tidak perlu agregasi khusus).

### Maskot ngintip

- Ukuran ±30 dp, pose kepala + dua tangan di tepi atas tab aktif, seolah melongok ke bawah. Gambar kode, keluarga
  gaya yang sama dengan maskot sekarang, warna dari tema, hewan sesuai tema.
- Pindah tab: maskot bergeser horizontal ke tab baru (±250 ms, sama dengan transisi tab).
  `disableAnimations` → langsung pindah.
- Maskot tidak menerima tap (tap tembus ke konten/menu) dan dikecualikan dari Semantics (dekoratif).
- Maskot di sapaan Beranda tetap ada.
- Menu bawah 4 tab tanpa tombol tengah. Maskot menonjol ±17 dp di atas menu; FAB di kanan bawah tidak bertabrakan
  karena maskot hanya di atas ikon tab dan tidak menerima tap.

## Diserahkan ke builder

- Nama widget frame dan nama field baru di `AppStyle`/`AppColors`; nilai warna muda kotak ringkasan per tema
  (asal lolos kontras dan dicatat di DESIGN.md).
- Jarak antar bagian yang menyesuaikan offset bayangan.
- Bentuk pose ngintip per hewan, selama satu keluarga gaya.
- Label sumbu grafik untuk rentang panjang.
- Test minimal: (1) kontras teks di kotak ringkasan tiap tema; (2) widget frame luar punya bayangan, frame dalam
  tidak; (3) tab Laporan berurutan Mingguan/Bulanan/Custom dan tidak ada Harian; (4) pilih rentang → memanggil
  `/reports/range` dengan `from`/`to` benar; (5) backend: sukses, `to < from` 400, > 366 hari 400, dompet user
  lain 404; (6) maskot pindah ke tab aktif, tanpa animasi saat `disableAnimations`, tidak menghalangi tap;
  (7) test yang ada tetap lolos.
- Docs: DESIGN.md (frame, laporan, maskot nav), PRD (laporan custom menggantikan harian), DECISIONS (keputusan
  baru), TASKS, openapi.yaml.

## Keputusan yang diambil Claude (cek ulang)

- Ketebalan garis 2 px dan offset bayangan (4, 4).
- Tema Gelap memakai garis/bayangan terang.
- Rentang bawaan Custom = awal bulan ini s.d. hari ini; tidak boleh memilih tanggal setelah hari ini.
- `comparison` Custom = periode sebelumnya dengan panjang sama.
- Selisih memakai warna "penting" tema (kuning di referensi).
- Endpoint `/reports/daily` dibiarkan di backend. Satu-satunya pemakai di app = `ReportType.daily`; dihapus.
- Panah kiri/kanan minggu/bulan dipertahankan.
- Garis frame = `onSurface` di semua tema.
