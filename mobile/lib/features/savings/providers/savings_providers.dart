import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../category/data/category_models.dart';
import '../../transaction/data/transaction_models.dart';
import '../../transaction/providers/transaction_providers.dart';
import '../../wallet/data/wallet_models.dart';
import '../../wallet/providers/wallet_providers.dart';

part 'savings_providers.g.dart';

/// Satu baris riwayat tabungan: setoran/penutupan (transfer) atau transaksi.
class SavingsEntry {
  const SavingsEntry({
    required this.occurredAt,
    required this.amount,
    this.transaction,
    this.transfer,
  });

  final DateTime occurredAt;

  /// Bertanda: + masuk ke tabungan, − keluar dari tabungan.
  final int amount;
  final Transaction? transaction;
  final Transfer? transfer;
}

// shortcut: hanya 100 transfer + 100 transaksi terbaru, tambah "muat lagi" jika riwayat melebihi itu.
@riverpod
Future<List<SavingsEntry>> savingsHistory(Ref ref, String savingsId) async {
  final (transfers, transactions) = await (
    ref.watch(walletApiProvider).transfers(walletId: savingsId),
    ref.watch(transactionApiProvider).list(walletId: savingsId, limit: 100),
  ).wait;
  return [
    for (final transfer in transfers)
      SavingsEntry(
        occurredAt: transfer.occurredAt,
        amount: transfer.toWallet.id == savingsId
            ? transfer.amount
            : -transfer.amount,
        transfer: transfer,
      ),
    for (final transaction in transactions)
      SavingsEntry(
        occurredAt: transaction.occurredAt,
        amount: transaction.type == TxType.income
            ? transaction.amount
            : -transaction.amount,
        transaction: transaction,
      ),
  ]..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
}
