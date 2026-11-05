import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/dates.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/money_widgets.dart';
import '../../../core/widgets/state_views.dart';
import '../../activity/data/activity_models.dart';
import '../../attachment/presentation/widgets/attachment_image.dart';
import '../../calendar/data/calendar_models.dart';
import '../../calendar/providers/calendar_providers.dart';
import '../../transaction/presentation/wallet_transactions_screen.dart';
import '../../transaction/presentation/widgets/add_sheet.dart';
import '../../wallet/presentation/transfers_screen.dart';

/// Halaman Hari (S-06). [date] = `YYYY-MM-DD`.
class DayScreen extends ConsumerWidget {
  const DayScreen({super.key, required this.date});

  final String date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = dayDetailProvider(date);
    final parsed = DateTime.parse(date);
    return Scaffold(
      appBar: AppBar(title: Text(formatLongDate(parsed))),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah',
        onPressed: () => showAddSheet(context, date: parsed),
        child: const Icon(Icons.add_rounded),
      ),
      body: ref
          .watch(provider)
          .when(
            loading: () => const ListSkeleton(),
            error: (error, _) => ErrorState(
              error: error,
              onRetry: () => ref.invalidate(provider),
            ),
            data: (day) => RefreshIndicator(
              onRefresh: () => ref.refresh(provider.future),
              child: _DayBody(day),
            ),
          ),
    );
  }
}

class _DayBody extends StatelessWidget {
  const _DayBody(this.day);

  final DayDetail day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmpty =
        day.transactions.isEmpty &&
        day.transfers.isEmpty &&
        day.activities.isEmpty;

    Widget section(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.xl,
        Spacing.lg,
        Spacing.xs,
      ),
      child: Text(title, style: theme.textTheme.titleMedium),
    );

    return ListView(
      padding: const EdgeInsets.only(bottom: Spacing.xxl * 2),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Row(
            children: [
              Expanded(child: _Total('Masuk', day.income)),
              Expanded(child: _Total('Keluar', -day.expense)),
            ],
          ),
        ),
        if (isEmpty)
          const EmptyState(
            message:
                'Belum ada catatan hari ini. Mulai dari pengeluaran pertamamu.',
          ),
        if (day.activities.isNotEmpty) section('Kegiatan'),
        for (final activity in day.activities) _ActivityTile(activity),
        if (day.transactions.isNotEmpty) section('Transaksi'),
        for (final transaction in day.transactions)
          TransactionTile(transaction),
        if (day.transfers.isNotEmpty) section('Transfer'),
        for (final transfer in day.transfers) TransferTile(transfer),
      ],
    );
  }
}

class _Total extends StatelessWidget {
  const _Total(this.label, this.amount);

  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        AmountText(amount, signed: true),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile(this.activity);

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: colors.activity, width: 3)),
      ),
      child: ListTile(
        title: Text(activity.title),
        subtitle: Text(formatActivityTime(activity.time)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (activity.isImportant)
              Icon(
                Icons.star_rounded,
                color: colors.important,
                semanticLabel: 'Penting',
              ),
            if (activity.attachments.isNotEmpty)
              ListThumbnail(activity.attachments),
          ],
        ),
        onTap: () => context.pushNamed(Routes.activityDetail, extra: activity),
      ),
    );
  }
}
