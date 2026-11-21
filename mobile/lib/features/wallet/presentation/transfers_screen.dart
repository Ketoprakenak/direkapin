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
      body: ref
          .watch(transfersProvider)
          .when(
            loading: () => const ListSkeleton(),
            error: (error, _) => ErrorState(
              error: error,
              onRetry: () => ref.invalidate(transfersProvider),
            ),
            data: (items) => items.isEmpty
                ? const Center(
                    child: EmptyState(message: 'Belum ada transfer.'),
                  )
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) => TransferTile(items[index]),
                  ),
          ),
    );
  }
}

class TransferTile extends StatelessWidget {
  const TransferTile(this.transfer, {super.key, this.walletId});

  final Transfer transfer;

  /// Diisi di riwayat satu dompet: judul dan nominal dilihat dari dompet itu.
  final String? walletId;

  @override
  Widget build(BuildContext context) {
    final when = transfer.occurredAt.toLocal();
    final incoming = walletId == transfer.toWallet.id;
    final other = incoming ? transfer.fromWallet : transfer.toWallet;
    return ListTile(
      leading: IconCircle(
        icon: walletId == null ? transfer.toWallet.icon : other.icon,
        color: walletId == null ? transfer.toWallet.color : other.color,
      ),
      title: Text(
        walletId == null
            ? '${transfer.fromWallet.name} ke ${transfer.toWallet.name}'
            : '${incoming ? 'Dari' : 'Ke'} ${other.name}',
      ),
      subtitle: Text(
        [
          transfer.note ?? '${formatShortDate(when)}, ${formatTime(when)}',
          if (transfer.fee > 0) 'biaya admin ${formatRupiah(transfer.fee)}',
        ].join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: walletId == null
          ? AmountText(transfer.amount)
          : AmountText(
              incoming ? transfer.amount : -transfer.amount,
              signed: true,
            ),
      onTap: () => context.pushNamed(Routes.transferDetail, extra: transfer),
    );
  }
}
