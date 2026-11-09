import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/dates.dart';
import '../../../core/format/money.dart';
import '../../../core/router/router.dart';
import '../../../core/widgets/money_widgets.dart';
import '../../../core/widgets/state_views.dart';
import '../data/wallet_models.dart';
import '../providers/wallet_providers.dart';

class TransfersScreen extends ConsumerWidget {
  const TransfersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat transfer')),
      body: ref.watch(transfersProvider).when(
        loading: () => const ListSkeleton(),
        error: (error, _) => ErrorState(
          error: error,
          onRetry: () => ref.invalidate(transfersProvider),
        ),
        data: (items) => items.isEmpty
            ? const Center(child: EmptyState(message: 'Belum ada transfer.'))
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) => TransferTile(items[index]),
              ),
      ),
    );
  }
}

class TransferTile extends StatelessWidget {
  const TransferTile(this.transfer, {super.key});

  final Transfer transfer;

  @override
  Widget build(BuildContext context) {
    final when = transfer.occurredAt.toLocal();
    return ListTile(
      leading: IconCircle(
        icon: transfer.toWallet.icon,
        color: transfer.toWallet.color,
      ),
      title: Text('${transfer.fromWallet.name} ke ${transfer.toWallet.name}'),
      subtitle: Text(
        [
          transfer.note ?? '${formatShortDate(when)}, ${formatTime(when)}',
          if (transfer.fee > 0) 'biaya admin ${formatRupiah(transfer.fee)}',
        ].join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: AmountText(transfer.amount),
      onTap: () => context.pushNamed(Routes.transferDetail, extra: transfer),
    );
  }
}
