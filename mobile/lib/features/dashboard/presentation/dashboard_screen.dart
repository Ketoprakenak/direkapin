import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_error.dart';
import '../../../core/format/dates.dart';
import '../../../core/format/money.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/frame.dart';
import '../../../core/widgets/mascot.dart';
import '../../../core/widgets/money_widgets.dart';
import '../../../core/widgets/state_views.dart';
import '../../category/data/category_models.dart';
import '../../recurring/data/recurring_models.dart';
import '../../recurring/presentation/widgets/record_sheet.dart';
import '../../recurring/providers/recurring_providers.dart';
import '../../settings/providers/settings_providers.dart';
import '../../transaction/presentation/wallet_transactions_screen.dart';
import '../../transaction/presentation/widgets/add_sheet.dart';
import '../../transaction/providers/transaction_providers.dart';
import '../data/dashboard_models.dart';
import '../providers/dashboard_providers.dart';
import 'widgets/expense_bar_chart.dart';
import 'widgets/update_banner.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    final name = ref.watch(meProvider).value?.name;
    final badge = _StreakBadges.highest(dashboard.value?.streak.longest ?? 0);
    return Scaffold(
      appBar: AppBar(
        title: name == null
            ? const Text('Beranda')
            : Row(
                children: [
                  Mascot(
                    size: Spacing.xl,
                    expression: dashboard.value?.today.hasEntry == true
                        ? MascotExpression.happy
                        : MascotExpression.neutral,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Flexible(
                    child: Text('Hai, $name', overflow: TextOverflow.ellipsis),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: Spacing.sm),
                    _TitleBadge(badge),
                  ],
                ],
              ),
        actions: [
          IconButton(
            tooltip: 'Cari transaksi',
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.pushNamed(Routes.transactionSearch),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddSheet(context),
        tooltip: 'Tambah',
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          const UpdateBanner(),
          Expanded(
            child: dashboard.when(
              data: (data) => RefreshIndicator(
                onRefresh: () {
                  ref.invalidate(recurringDueProvider);
                  return ref.refresh(dashboardProvider.future);
                },
                child: _DashboardBody(data),
              ),
              error: (error, _) => ErrorState(
                error: error,
                onRetry: () => ref.invalidate(dashboardProvider),
              ),
              loading: () => const _DashboardSkeleton(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Spacing.lg),
      children: const [
        Skeleton(height: 140),
        SizedBox(height: Spacing.md),
        Skeleton(height: 96),
        SizedBox(height: Spacing.md),
        Skeleton(height: 180),
      ],
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody(this.data);

  final Dashboard data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        0,
        Spacing.lg,
        Spacing.xxl * 2,
      ),
      children: [
        _BalanceCard(data),
        const SizedBox(height: Spacing.xl),
        if (data.streak.current > 0 || data.streak.longest > 0) ...[
          FrameCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.streak.current > 0)
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        color: colors.important,
                      ),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: Text(
                          '${data.streak.current} hari berturut-turut mencatat',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                if (data.streak.longest > 0) ...[
                  if (data.streak.current > 0)
                    const SizedBox(height: Spacing.sm),
                  _StreakBadges(data.streak.longest),
                ],
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),
        ],
        FrameCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pengeluaran 7 hari', style: theme.textTheme.titleMedium),
              const SizedBox(height: Spacing.md),
              ExpenseBarChart(
                points: data.last7Days,
                barWidth: Spacing.lg,
                labelOf: (point) => formatWeekday(DateTime.parse(point.label)),
                showAxis: true,
              ),
            ],
          ),
        ),
        const _RecentTransactions(),
        const _RecurringDue(),
        const SizedBox(height: Spacing.xl),
        FrameCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Hari ini', style: theme.textTheme.titleMedium),
              const SizedBox(height: Spacing.sm),
              if (!data.today.hasEntry)
                const EmptyState(
                  message: 'Belum ada catatan hari ini. Mulai dari pengeluaran pertamamu.',
                )
              else ...[
                // Masuk hari ini = titik terakhir grafik 7 hari; `today` hanya punya pengeluaran.
                if ((data.last7Days.lastOrNull?.income ?? 0) > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.sm),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Masuk hari ini',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        AmountText(data.last7Days.last.income, signed: true),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Keluar hari ini',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    AmountText(-data.today.expense),
                  ],
                ),
                for (final activity in data.today.activities)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      activity.isImportant
                          ? Icons.star_rounded
                          : Icons.event_note_rounded,
                      color: activity.isImportant
                          ? colors.important
                          : colors.activity,
                    ),
                    title: Text(activity.title),
                    subtitle: Text(formatActivityTime(activity.time)),
                    onTap: () => context.pushNamed(
                      Routes.activityDetail,
                      extra: activity,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Badge tertinggi di sebelah nama pada judul Beranda (ENG-02).
class _TitleBadge extends StatelessWidget {
  const _TitleBadge(this.level);

  final int level;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Badge $level hari',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.military_tech_rounded,
            color: AppColors.of(context).important,
          ),
          Text('$level', style: theme.textTheme.labelLarge),
        ],
      ),
    );
  }
}

/// Badge streak 7, 30, 100 hari (ENG-02), dari streak terpanjang supaya tidak hilang.
class _StreakBadges extends StatelessWidget {
  const _StreakBadges(this.longest);

  static const _levels = [7, 30, 100];

  /// Badge tertinggi yang sudah didapat, atau null.
  static int? highest(int longest) =>
      _levels.reversed.where((level) => longest >= level).firstOrNull;

  final int longest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: [
        for (final level in _levels)
          Semantics(
            label: longest >= level
                ? 'Badge $level hari didapat'
                : 'Badge $level hari belum didapat',
            excludeSemantics: true,
            child: FrameBox(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    longest >= level
                        ? Icons.military_tech_rounded
                        : Icons.lock_outline_rounded,
                    size: Spacing.lg,
                    color: longest >= level
                        ? colors.important
                        : theme.colorScheme.outline,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text('$level hari', style: theme.textTheme.labelLarge),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// 3 transaksi terakhir (DSH-04); tap membuka detail transaksi.
class _RecentTransactions extends ConsumerWidget {
  const _RecentTransactions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ref
        .watch(recentTransactionsProvider)
        .when(
          loading: () => const Padding(
            padding: EdgeInsets.only(top: Spacing.xl),
            child: Skeleton(height: 120),
          ),
          // Bagian tambahan; Beranda tetap bisa dipakai walau daftar gagal dimuat.
          error: (_, _) => const SizedBox.shrink(),
          data: (items) {
            if (items.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: Spacing.xl),
                FrameCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Transaksi terakhir',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: Spacing.sm),
                      ListTileTheme.merge(
                        contentPadding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (final item in items) TransactionTile(item),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
  }
}

/// Transaksi berulang yang jatuh tempo (FIN-15); tersembunyi jika kosong/gagal.
class _RecurringDue extends ConsumerStatefulWidget {
  const _RecurringDue();

  @override
  ConsumerState<_RecurringDue> createState() => _RecurringDueState();
}

class _RecurringDueState extends ConsumerState<_RecurringDue> {
  // Aturan yang sedang diproses; mencegah ketukan ganda.
  final _busy = <String>{};

  // body mengembalikan true jika request benar-benar terkirim.
  Future<void> _run(RecurringDue due, Future<bool> Function() body) async {
    final id = due.recurring.id;
    if (!_busy.add(id)) return;
    setState(() {});
    final messenger = ScaffoldMessenger.of(context);
    var sent = false;
    try {
      sent = await body();
    } on ApiException catch (e) {
      sent = true;
      // CONFLICT = sudah ditangani di perangkat lain; daftar disegarkan di bawah.
      final archived = e.details.containsKey('walletId');
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            archived
                ? 'Dompet aturan sudah diarsipkan. Ubah aturan dulu.'
                : e.message,
          ),
        ),
      );
    } finally {
      if (mounted) {
        _busy.remove(id);
        if (sent) refreshMoney(ref);
        setState(() {});
      }
    }
  }

  Future<void> _record(RecurringDue due) => _run(due, () async {
    final result = await showRecordSheet(context, due);
    if (result == null || !mounted) return false;
    await ref.read(recurringApiProvider).record(due.recurring.id, {
      'month': due.month,
      'amount': result.amount,
      'occurredAt': result.date.toUtc().toIso8601String(),
    });
    return true;
  });

  Future<void> _skip(RecurringDue due) => _run(due, () async {
    final confirmed = await confirmDialog(
      context,
      message:
          'Lewati ${due.recurring.category.name} untuk ${formatMonth(DateTime.parse('${due.month}-01'))}?',
      confirmLabel: 'Lewati',
    );
    if (!confirmed || !mounted) return false;
    await ref.read(recurringApiProvider).skip(due.recurring.id, due.month);
    return true;
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = ref.watch(recurringDueProvider).value ?? const [];
    if (items.isEmpty) return const SizedBox.shrink();
    const buttonSize = Size(Spacing.xxl, Spacing.xxl + Spacing.lg);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: Spacing.xl),
        FrameCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Jatuh tempo', style: theme.textTheme.titleMedium),
              for (final due in items) ...[
                const SizedBox(height: Spacing.sm),
                Row(
                  children: [
                    IconCircle(
                      icon: due.recurring.category.icon,
                      color: due.recurring.category.color,
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            due.recurring.category.name,
                            style: theme.textTheme.bodyLarge,
                          ),
                          Text(
                            'Jatuh tempo ${formatLongDate(DateTime.parse(due.dueDate))}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    AmountText(
                      due.recurring.type == TxType.expense
                          ? -due.recurring.amount
                          : due.recurring.amount,
                      signed: true,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Semantics(
                      label: 'Lewati ${due.recurring.category.name}',
                      child: TextButton(
                        style: TextButton.styleFrom(minimumSize: buttonSize),
                        onPressed: _busy.contains(due.recurring.id)
                            ? null
                            : () => _skip(due),
                        child: const Text('Lewati'),
                      ),
                    ),
                    Semantics(
                      label: 'Catat ${due.recurring.category.name}',
                      child: FilledButton(
                        style: FilledButton.styleFrom(minimumSize: buttonSize),
                        onPressed: _busy.contains(due.recurring.id)
                            ? null
                            : () => _record(due),
                        child: const Text('Catat'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatefulWidget {
  const _BalanceCard(this.data);

  final Dashboard data;

  @override
  State<_BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<_BalanceCard> {
  // Tersembunyi tiap Beranda dibuka, supaya saldo tidak terlihat orang di sekitar.
  bool _hidden = true;
  bool _showDetail = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final theme = Theme.of(context);
    final colors = AppColors.of(context);
    Widget monthColumn(String label, int amount, Color color) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          Text(
            formatRupiah(amount),
            style: theme.textTheme.titleSmall?.copyWith(color: color),
          ),
        ],
      ),
    );

    return FrameCard(
      padding: const EdgeInsets.all(Spacing.lg),
      color: theme.colorScheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Total saldo', style: theme.textTheme.bodyMedium),
              IconButton(
                tooltip: _hidden ? 'Tampilkan saldo' : 'Sembunyikan saldo',
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  _hidden
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                ),
                onPressed: () => setState(() => _hidden = !_hidden),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: _hidden
                ? Text('Rp••••••', style: theme.textTheme.headlineMedium)
                : AmountText(data.totalBalance, large: true),
          ),
          TextButton.icon(
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: () => setState(() => _showDetail = !_showDetail),
            icon: Icon(
              _showDetail
                  ? Icons.expand_less_rounded
                  : Icons.expand_more_rounded,
            ),
            label: Text(
              _showDetail ? 'Sembunyikan detail' : 'Tampilkan detail',
            ),
          ),
          if (_showDetail)
            Row(
              children: [
                monthColumn(
                  'Masuk bulan ini',
                  data.month.income,
                  colors.income,
                ),
                monthColumn(
                  'Keluar bulan ini',
                  data.month.expense,
                  colors.expense,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
