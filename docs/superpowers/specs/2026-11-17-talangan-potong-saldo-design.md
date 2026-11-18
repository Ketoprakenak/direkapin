# Utang ditalangin memotong "Bisa digunakan" (FIN-20 revisi) — design

Status: draft, menunggu persetujuan owner (kontrak dashboard bertambah satu field).

## Kebutuhan owner (2026-11-17)

Utang **ditalangin** = "utang gantung" yang pasti harus dibayar, jadi uang yang benar-benar bisa dipakai sudah berkurang sejak utang dicatat. **Pinjam tunai tidak** ikut, karena uangnya memang untuk dipakai.

| Kejadian (dompet Rp1.000.000, ditalangin Rp50.000) | Saldo total | Bisa digunakan |
|---|---|---|
| Sebelum | 1.000.000 | 1.000.000 |
| Utang ditalangin dicatat | 1.000.000 | **950.000** |
| Bayar cicilan 20.000 | **980.000** | 950.000 |
| Bayar sisa 30.000 (lunas) | **950.000** | 950.000 |

## Aturan

- Utang ditalangin = `Receivable` `PAYABLE` dengan `loanTransactionId = null` (catatan pinjam tunai yang transaksi pinjamannya dihapus juga dihitung ditalangin, karena uangnya tidak pernah ada di dompet).
- `dashboard.frontedPayableRemaining` (baru) = Σ sisa utang ditalangin.
- `dashboard.availableBalance` = Σ saldo dompet non-tabungan − `frontedPayableRemaining` (boleh negatif).
- `dashboard.totalBalance` = Σ saldo dompet non-tabungan + Σ tabungan (angka **tidak berubah** dari sekarang).
- Saldo per dompet, `GET /wallets.totalBalance`, laporan, dan budget **tidak berubah**.

## UI

- Sheet Saldo total, baris **Bisa digunakan**: angka baru; bila `frontedPayableRemaining > 0` tampil keterangan `Sudah dipotong utang ditalangin Rp…` (ikut mode sembunyi). Negatif = merah (`AmountText`).
- Tidak ada perubahan di Beranda (menampilkan Saldo total).

## Di luar cakupan

Pinjam tunai, memotong saldo per dompet, piutang menambah Bisa digunakan.
