import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../data/transaction_api.dart';
import '../data/transaction_models.dart';

part 'transaction_providers.g.dart';

@riverpod
TransactionApi transactionApi(Ref ref) =>
    TransactionApi(ref.watch(apiClientProvider));

// shortcut: hanya 100 transaksi terbaru, tambah "muat lagi" jika riwayatnya melebihi itu.
@riverpod
Future<List<Transaction>> walletTransactions(Ref ref, String walletId) =>
    ref.watch(transactionApiProvider).list(walletId: walletId, limit: 100);

// shortcut: hanya 100 hasil terbaru; tambah "muat lagi" jika hasil cari sering melebihi itu.
/// Cari & filter transaksi (FIN-11). [type] = `INCOME`/`EXPENSE`, tanggal `YYYY-MM-DD`.
@riverpod
Future<List<Transaction>> searchTransactions(
  Ref ref, {
  String? query,
  String? walletId,
  String? categoryId,
  String? type,
  String? from,
  String? to,
}) => ref
    .watch(transactionApiProvider)
    .list(
      query: query,
      walletId: walletId,
      categoryId: categoryId,
      type: type,
      from: from,
      to: to,
      limit: 100,
    );

/// 3 transaksi terbaru untuk Beranda (DSH-04).
@riverpod
Future<List<Transaction>> recentTransactions(Ref ref) =>
    ref.watch(transactionApiProvider).list(limit: 3);

/// Dompet transaksi terakhir, untuk pilihan awal di form (D-31).
@riverpod
Future<String?> lastUsedWalletId(Ref ref) async {
  final latest = await ref.watch(transactionApiProvider).list(limit: 1);
  return latest.firstOrNull?.wallet.id;
}
