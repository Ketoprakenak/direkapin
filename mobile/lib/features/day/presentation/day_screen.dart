import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_error.dart';
import '../../../core/format/dates.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/frame.dart';
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

    Widget group(String title, List<Widget> items) => Padding(
      padding: const EdgeInsets.only(top: Spacing.lg),
      child: FrameCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: Spacing.xs),
            ListTileTheme.merge(
              contentPadding: EdgeInsets.zero,
              child: Column(children: items),
            ),
          ],
        ),
      ),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.sm,
        Spacing.lg,
        Spacing.xxl * 2,
      ),
      children: [
        FrameCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: _Total('Masuk', day.income)),
                  Expanded(child: _Total('Keluar', -day.expense)),
                ],
              ),
              _MoodPicker(date: day.date, mood: day.note?.mood),
            ],
          ),
        ),
        if (isEmpty)
          const EmptyState(
            message:
                'Belum ada catatan hari ini. Mulai dari pengeluaran pertamamu.',
          ),
        if (day.activities.isNotEmpty)
          group('Kegiatan', [
            for (final activity in day.activities) _ActivityTile(activity),
          ]),
        if (day.transactions.isNotEmpty)
          group('Transaksi', [
            for (final transaction in day.transactions)
              TransactionTile(transaction),
          ]),
        if (day.transfers.isNotEmpty)
          group('Transfer', [
            for (final transfer in day.transfers) TransferTile(transfer),
          ]),
      ],
    );
  }
}

/// Mood harian (ACT-05). Tap mood yang sama untuk menghapusnya.
class _MoodPicker extends ConsumerStatefulWidget {
  const _MoodPicker({required this.date, required this.mood});

  static const moods = ['😄', '🙂', '😐', '😕', '😢'];

  final String date;
  final String? mood;

  @override
  ConsumerState<_MoodPicker> createState() => _MoodPickerState();
}

class _MoodPickerState extends ConsumerState<_MoodPicker> {
  late String? _mood = widget.mood;
  bool _saving = false;

  @override
  void didUpdateWidget(_MoodPicker old) {
    super.didUpdateWidget(old);
    if (old.mood != widget.mood) _mood = widget.mood;
  }

  Future<void> _select(String mood) async {
    final previous = _mood;
    final next = mood == previous ? null : mood;
    setState(() {
      _mood = next;
      _saving = true;
    });
    try {
      await saveMood(ref.read(apiClientProvider), widget.date, next);
      ref.invalidate(dayDetailProvider(widget.date));
      ref.invalidate(calendarMonthProvider);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _mood = previous);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.md),
      // Wrap, bukan Row: 5 chip + label bisa melebihi lebar HP kecil.
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Mood', style: theme.textTheme.titleMedium),
          const SizedBox(width: Spacing.md),
          for (final mood in _MoodPicker.moods)
            Padding(
              padding: const EdgeInsets.only(right: Spacing.xs),
              child: ChoiceChip(
                label: Text(mood),
                selected: _mood == mood,
                showCheckmark: false,
                onSelected: _saving ? null : (_) => _select(mood),
              ),
            ),
        ],
      ),
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
      margin: const EdgeInsets.symmetric(vertical: Spacing.xs),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: colors.activity, width: 3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.md),
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
