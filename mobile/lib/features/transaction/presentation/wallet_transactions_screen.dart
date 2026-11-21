import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_error.dart';
import '../../../core/format/dates.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/money_widgets.dart';
import '../../../core/widgets/state_views.dart';
import '../../attachment/presentation/widgets/attachment_image.dart';
import '../../category/data/category_models.dart';
import '../../wallet/data/wallet_models.dart';
import '../../wallet/presentation/transfers_screen.dart';
import '../../wallet/providers/wallet_providers.dart';
import '../data/transaction_models.dart';
import '../providers/transaction_providers.dart';

/// Riwayat dompet: transaksi dan transfer, supaya cocok dengan saldonya.
class WalletTransactionsScreen extends ConsumerStatefulWidget {
  const WalletTransactionsScreen({
    super.key,
    required this.walletId,
    required this.walletName,
  });

  final String walletId;
  final String walletName;

  @override
  ConsumerState<WalletTransactionsScreen> createState() =>
      _WalletTransactionsScreenState();
}

class _WalletTransactionsScreenState
    extends ConsumerState<WalletTransactionsScreen> {
  var _loadingMore = false;

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(walletTransactionsProvider(widget.walletId).notifier)
          .loadMore();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = walletTransactionsProvider(widget.walletId);
    final wallet = ref
        .watch(walletsProvider(includeArchived: true))
        .value
        ?.where((w) => w.id == widget.walletId)
        .firstOrNull;
    return Scaffold(
      appBar: AppBar(title: Text(widget.walletName)),
      body: ref
          .watch(provider)
          .when(
            loading: () => const ListSkeleton(),
            error: (error, _) => ErrorState(
              error: error,
              onRetry: () => ref.invalidate(provider),
            ),
            data: (history) {
              final entries = history.entries;
              if (entries.isEmpty && !history.hasMore) {
                return const Center(
                  child: EmptyState(
                    message: 'Belum ada transaksi di dompet ini.',
                  ),
                );
              }
              return ListView(
                children: [
                  for (final entry in entries)
                    switch (entry) {
                      Transfer() => TransferTile(
                        entry,
                        walletId: widget.walletId,
                      ),
                      _ => TransactionTile(entry as Transaction),
                    },
                  if (history.hasMore)
                    Padding(
                      padding: const EdgeInsets.all(Spacing.lg),
                      child: Center(
                        child: _loadingMore
                            ? const CircularProgressIndicator()
                            : OutlinedButton(
                                onPressed: _loadMore,
                                child: const Text('Muat lagi'),
                              ),
                      ),
                    )
                  else if (wallet != null)
                    ListTile(
                      minTileHeight: Spacing.xxl * 2,
                      leading: const Icon(Icons.flag_rounded),
                      title: const Text('Saldo awal'),
                      trailing: AmountText(wallet.initialBalance),
                    ),
                ],
              );
            },
          ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  const TransactionTile(this.transaction, {super.key});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final when = transaction.occurredAt.toLocal();
    final amount = transaction.type == TxType.income
        ? transaction.amount
        : -transaction.amount;
    return ListTile(
      minTileHeight: Spacing.xxl * 2,
      leading: IconCircle(
        icon: transaction.category.icon,
        color: transaction.category.color,
      ),
      title: Text(transaction.category.name),
      subtitle: Text(
        transaction.note ?? '${formatShortDate(when)}, ${formatTime(when)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AmountText(amount, signed: true),
          if (transaction.attachments.isNotEmpty)
            ListThumbnail(transaction.attachments),
        ],
      ),
      onTap: () =>
          context.pushNamed(Routes.transactionDetail, extra: transaction),
    );
  }
}
