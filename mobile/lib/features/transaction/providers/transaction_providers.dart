import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../wallet/data/wallet_models.dart';
import '../../wallet/providers/wallet_providers.dart';
import '../data/transaction_api.dart';
import '../data/transaction_models.dart';

part 'transaction_providers.g.dart';

@riverpod
TransactionApi transactionApi(Ref ref) =>
    TransactionApi(ref.watch(apiClientProvider));

/// Riwayat dompet (S-12): transaksi + transfer, karena saldo ikut berubah oleh keduanya.
class WalletHistory {
  const WalletHistory({required this.transactions, required this.transfers});

  final ApiPage<Transaction> transactions;
  final ApiPage<Transfer> transfers;

  bool get hasMore =>
      transactions.nextCursor != null || transfers.nextCursor != null;

  /// [Transaction] atau [Transfer], terbaru di atas. Item yang lebih lama dari
  /// item terakhir sumber yang belum habis ditahan dulu: urutannya belum pasti.
  List<Object> get entries {
    final cuts = [
      if (transactions.nextCursor != null)
        transactions.items.lastOrNull?.occurredAt,
      if (transfers.nextCursor != null) transfers.items.lastOrNull?.occurredAt,
    ].nonNulls;
    final cut = cuts.isEmpty
        ? null
        : cuts.reduce((a, b) => a.isAfter(b) ? a : b);
    final all = <({DateTime at, Object item})>[
      for (final t in transactions.items) (at: t.occurredAt, item: t),
      for (final t in transfers.items) (at: t.occurredAt, item: t),
    ]..sort((a, b) => b.at.compareTo(a.at));
    return [
      for (final e in all)
        if (cut == null || !e.at.isBefore(cut)) e.item,
    ];
  }
}

@riverpod
class WalletTransactions extends _$WalletTransactions {
  @override
  Future<WalletHistory> build(String walletId) async {
    final (transactions, transfers) = await (
      ref.watch(transactionApiProvider).page(walletId: walletId),
      ref.watch(walletApiProvider).transferPage(walletId: walletId),
    ).wait;
    return WalletHistory(transactions: transactions, transfers: transfers);
  }

  /// Halaman berikutnya dari sumber yang belum habis.
  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore) return;
    Future<ApiPage<T>> next<T>(
      ApiPage<T> page,
      Future<ApiPage<T>> Function(String cursor) fetch,
    ) async {
      final cursor = page.nextCursor;
      if (cursor == null) return page;
      final more = await fetch(cursor);
      return (
        items: [...page.items, ...more.items],
        nextCursor: more.nextCursor,
      );
    }

    final (transactions, transfers) = await (
      next(
        current.transactions,
        (cursor) => ref
            .read(transactionApiProvider)
            .page(walletId: walletId, cursor: cursor),
      ),
      next(
        current.transfers,
        (cursor) => ref
            .read(walletApiProvider)
            .transferPage(walletId: walletId, cursor: cursor),
      ),
    ).wait;
    state = AsyncData(
      WalletHistory(transactions: transactions, transfers: transfers),
    );
  }
}

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
