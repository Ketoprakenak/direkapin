import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/dates.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/frame.dart';
import '../../../core/widgets/money_widgets.dart';
import '../../../core/widgets/state_views.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../wallet/data/wallet_models.dart';
import '../providers/savings_providers.dart';
import 'savings_sheet.dart';

/// Riwayat tabungan (FIN-18): kapan disetor dan kapan dipakai, per bulan.
class SavingsHistoryScreen extends ConsumerWidget {
  const SavingsHistoryScreen({super.key, required this.savingsId});

  final String savingsId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    final history = ref.watch(savingsHistoryProvider(savingsId));
    final savings = dashboard.value?.savings
        .where((s) => s.id == savingsId)
        .firstOrNull;
    void retry() {
      ref.invalidate(dashboardProvider);
      ref.invalidate(savingsHistoryProvider(savingsId));
    }

    return Scaffold(
      appBar: AppBar(title: Text(savings?.name ?? 'Riwayat tabungan')),
      body: switch ((dashboard, history)) {
        (AsyncError(:final error), _) || (_, AsyncError(:final error)) =>
          ErrorState(error: error, onRetry: retry),
        (AsyncData(), AsyncData(value: final entries)) when savings != null =>
          _History(savings, entries),
        (AsyncData(), AsyncData()) => const Center(
          child: EmptyState(message: 'Tabungan ini sudah dihapus.'),
        ),
        _ => const ListSkeleton(),
      },
    );
  }
}

class _History extends StatelessWidget {
  const _History(this.savings, this.entries);

  final Wallet savings;
  final List<SavingsEntry> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var deposited = 0;
    var used = 0;
    for (final entry in entries) {
      if (entry.amount > 0) {
        deposited += entry.amount;
      } else {
        used -= entry.amount;
      }
    }

    Widget total(String label, int amount) => Expanded(
      child: FrameBox(
        padding: const EdgeInsets.all(Spacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelSmall),
            AmountText(amount),
          ],
        ),
      ),
    );

    final rows = <Widget>[];
    String? lastMonth;
    for (final entry in entries) {
      final month = formatMonth(entry.occurredAt.toLocal());
      if (month != lastMonth) {
        lastMonth = month;
        rows.add(
          Padding(
            padding: const EdgeInsets.only(top: Spacing.lg, bottom: Spacing.xs),
            child: Text(month, style: theme.textTheme.titleMedium),
          ),
        );
      }
      rows.add(_EntryTile(entry));
    }

    return ListView(
      padding: const EdgeInsets.all(Spacing.lg),
      children: [
        FrameCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Saldo', style: theme.textTheme.bodyMedium),
              AmountText(savings.balance, large: true),
              SavingsProgress(savings, hidden: false),
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  total('Disetor', deposited),
                  const SizedBox(width: Spacing.sm),
                  total('Dipakai', used),
                ],
              ),
            ],
          ),
        ),
        if (entries.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: Spacing.xl),
            child: EmptyState(message: 'Belum ada setoran atau pengeluaran.'),
          ),
        ...rows,
      ],
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile(this.entry);

  final SavingsEntry entry;

  @override
  Widget build(BuildContext context) {
    final when = entry.occurredAt.toLocal();
    final date = '${formatShortDate(when)}, ${formatTime(when)}';
    final transfer = entry.transfer;
    final transaction = entry.transaction;
    final incoming = entry.amount > 0;
    final String title;
    final String? note;
    if (transfer != null) {
      title = incoming
          ? 'Setor dari ${transfer.fromWallet.name}'
          : 'Ke ${transfer.toWallet.name}';
      note = transfer.note;
    } else {
      title = transaction!.category.name;
      note = transaction.note;
    }
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: FrameBox(
        padding: const EdgeInsets.all(Spacing.xs),
        child: Icon(
          incoming ? Icons.south_west_rounded : Icons.north_east_rounded,
          semanticLabel: incoming ? 'Masuk' : 'Keluar',
        ),
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        note == null ? date : '$note · $date',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: AmountText(entry.amount, signed: true),
      onTap: () => transfer != null
          ? context.pushNamed(Routes.transferDetail, extra: transfer)
          : context.pushNamed(Routes.transactionDetail, extra: transaction),
    );
  }
}
