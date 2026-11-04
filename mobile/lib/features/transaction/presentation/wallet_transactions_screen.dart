import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/dates.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/money_widgets.dart';
import '../../../core/widgets/state_views.dart';
import '../../category/data/category_models.dart';
import '../data/transaction_models.dart';
import '../providers/transaction_providers.dart';

class WalletTransactionsScreen extends ConsumerWidget {
  const WalletTransactionsScreen({
    super.key,
    required this.walletId,
    required this.walletName,
  });

  final String walletId;
  final String walletName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = walletTransactionsProvider(walletId);
    return Scaffold(
      appBar: AppBar(title: Text(walletName)),
      body: ref.watch(provider).when(
        loading: () => const ListSkeleton(),
        error: (error, _) => ErrorState(
          error: error,
          onRetry: () => ref.invalidate(provider),
        ),
        data: (items) => items.isEmpty
            ? const Center(
                child: EmptyState(message: 'Belum ada transaksi di dompet ini.'),
              )
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) => TransactionTile(items[index]),
              ),
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
      trailing: AmountText(amount, signed: true),
    );
  }
}
