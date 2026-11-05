import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/dates.dart';
import '../../../core/format/money.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/money_widgets.dart';
import '../../../core/widgets/state_views.dart';
import '../../dashboard/presentation/widgets/expense_bar_chart.dart';
import '../../transaction/presentation/wallet_transactions_screen.dart';
import '../../wallet/data/wallet_models.dart';
import '../../wallet/providers/wallet_providers.dart';
import '../data/report_models.dart';
import '../providers/report_providers.dart';
import 'category_transactions_screen.dart';

/// Nilai pilihan "Semua dompet" di filter.
const _allWallets = '';

/// Senin dari minggu yang memuat [date] (minggu = Senin-Minggu).
DateTime mondayOf(DateTime date) =>
    DateTime(date.year, date.month, date.day - (date.weekday - 1));

/// Laporan (S-10).
class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  ReportType _type = ReportType.monthly;
  DateTime _anchor = DateTime.now();
  String _walletId = _allWallets;

  String get _key => switch (_type) {
    ReportType.daily => dateKey(_anchor),
    ReportType.weekly => dateKey(mondayOf(_anchor)),
    ReportType.monthly => monthKey(_anchor),
  };

  String get _label {
    switch (_type) {
      case ReportType.daily:
        return formatLongDate(_anchor);
      case ReportType.weekly:
        final monday = mondayOf(_anchor);
        final sunday = DateTime(monday.year, monday.month, monday.day + 6);
        return '${formatShortDate(monday)} – ${formatShortDate(sunday)}';
      case ReportType.monthly:
        return formatMonth(_anchor);
    }
  }

  void _shift(int direction) {
    setState(() {
      final date = _anchor;
      _anchor = switch (_type) {
        ReportType.daily => DateTime(
          date.year,
          date.month,
          date.day + direction,
        ),
        ReportType.weekly => DateTime(
          date.year,
          date.month,
          date.day + 7 * direction,
        ),
        // Tanggal 1: tanggal 31 bisa melompati bulan yang lebih pendek.
        ReportType.monthly => DateTime(date.year, date.month + direction),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsProvider(includeArchived: true)).value;
    // Dompet terpilih bisa saja sudah dihapus dari layar Dompet.
    final walletGone =
        wallets != null && !wallets.any((wallet) => wallet.id == _walletId);
    final walletId = _walletId == _allWallets || walletGone ? null : _walletId;
    final provider = reportProvider(_type, _key, walletId: walletId);

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          SegmentedButton<ReportType>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: ReportType.daily, label: Text('Harian')),
              ButtonSegment(value: ReportType.weekly, label: Text('Mingguan')),
              ButtonSegment(value: ReportType.monthly, label: Text('Bulanan')),
            ],
            selected: {_type},
            onSelectionChanged: (selected) =>
                setState(() => _type = selected.first),
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              IconButton(
                tooltip: 'Periode sebelumnya',
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => _shift(-1),
              ),
              Expanded(
                child: Text(
                  _label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Periode berikutnya',
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () => _shift(1),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          _WalletFilter(
            wallets: wallets ?? const [],
            selected: walletId ?? _allWallets,
            onChanged: (value) => setState(() => _walletId = value),
          ),
          const SizedBox(height: Spacing.lg),
          ref
              .watch(provider)
              .when(
                loading: () => const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Skeleton(height: Spacing.xxl * 2),
                    SizedBox(height: Spacing.md),
                    Skeleton(height: Spacing.xxl * 5),
                  ],
                ),
                error: (error, _) => ErrorState(
                  error: error,
                  onRetry: () => ref.invalidate(provider),
                ),
                data: (report) => _ReportBody(
                  report: report,
                  type: _type,
                  walletId: walletId,
                ),
              ),
        ],
      ),
    );
  }
}

class _WalletFilter extends StatelessWidget {
  const _WalletFilter({
    required this.wallets,
    required this.selected,
    required this.onChanged,
  });

  final List<Wallet> wallets;
  final String selected;
  final void Function(String walletId) onChanged;

  @override
  Widget build(BuildContext context) {
    final hasSelected =
        selected == _allWallets || wallets.any((w) => w.id == selected);
    return DropdownButtonFormField<String>(
      key: ValueKey('$selected-${wallets.length}'),
      initialValue: hasSelected ? selected : _allWallets,
      decoration: const InputDecoration(labelText: 'Dompet'),
      items: [
        const DropdownMenuItem(value: _allWallets, child: Text('Semua dompet')),
        // Dompet arsip tetap ada supaya laporan lamanya bisa dibuka.
        for (final wallet in wallets)
          DropdownMenuItem(
            value: wallet.id,
            child: Text(
              wallet.isArchived ? '${wallet.name} (arsip)' : wallet.name,
            ),
          ),
      ],
      onChanged: (value) => onChanged(value ?? _allWallets),
    );
  }
}

class _ReportBody extends StatelessWidget {
  const _ReportBody({
    required this.report,
    required this.type,
    required this.walletId,
  });

  final Report report;
  final ReportType type;
  final String? walletId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totals = report.totals;
    Widget section(String title) => Padding(
      padding: const EdgeInsets.only(top: Spacing.xl, bottom: Spacing.sm),
      child: Text(title, style: theme.textTheme.titleMedium),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _Total('Masuk', totals.income)),
            Expanded(child: _Total('Keluar', -totals.expense)),
            Expanded(child: _Total('Selisih', totals.net)),
          ],
        ),
        if (report.comparison case final comparison?) ...[
          const SizedBox(height: Spacing.md),
          Text(_comparisonText(comparison), style: theme.textTheme.bodyMedium),
        ],
        if (totals.transactionCount == 0)
          const EmptyState(message: 'Belum ada transaksi di periode ini.')
        else ...[
          if (report.series.isNotEmpty) ...[
            section('Pengeluaran'),
            _seriesChart(),
          ],
          if (report.byCategory.isNotEmpty) ...[
            section('Pengeluaran per kategori'),
            if (type == ReportType.monthly) ...[
              _CategoryDonut(report.byCategory),
              const SizedBox(height: Spacing.md),
            ],
            for (final item in report.byCategory)
              _CategoryTile(item, period: report.period, walletId: walletId),
          ],
          if (type == ReportType.daily) ...[
            section('Transaksi'),
            _DayTransactions(day: report.period.start, walletId: walletId),
          ],
        ],
      ],
    );
  }

  Widget _seriesChart() {
    if (type == ReportType.weekly) {
      return ExpenseBarChart(
        points: report.series,
        barWidth: Spacing.lg,
        labelOf: (point) => formatWeekday(DateTime.parse(point.label)),
      );
    }
    return ExpenseBarChart(
      points: report.series,
      barWidth: Spacing.sm,
      labelOf: (point) {
        // Label tiap 5 hari: 31 label tidak muat dalam satu baris.
        final day = DateTime.parse(point.label).day;
        return day == 1 || day % 5 == 0 ? '$day' : '';
      },
    );
  }

  String _comparisonText(ReportComparison comparison) {
    final pct = comparison.changePct;
    if (pct == null) return 'Bulan lalu belum ada pengeluaran.';
    final previous = formatRupiah(comparison.previousExpense);
    final rounded = pct.abs().round();
    if (rounded == 0) return 'Pengeluaran sama dengan bulan lalu ($previous).';
    final direction = pct > 0 ? 'naik' : 'turun';
    return 'Pengeluaran $direction $rounded% dari bulan lalu ($previous).';
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
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: AmountText(amount, signed: true),
        ),
      ],
    );
  }
}

class _CategoryDonut extends StatelessWidget {
  const _CategoryDonut(this.items);

  final List<CategoryShare> items;

  @override
  Widget build(BuildContext context) {
    final summary = [
      for (final item in items)
        '${item.category.name} ${(item.share * 100).round()}%',
    ].join(', ');
    return Semantics(
      label: 'Grafik pengeluaran per kategori: $summary',
      excludeSemantics: true,
      child: SizedBox(
        height: Spacing.xxl * 6,
        child: PieChart(
          PieChartData(
            centerSpaceRadius: Spacing.xxl * 1.5,
            sectionsSpace: Spacing.xs / 2,
            sections: [
              for (final item in items)
                PieChartSectionData(
                  value: item.amount.toDouble(),
                  color: colorFromHex(item.category.color),
                  radius: Spacing.xl,
                  showTitle: false,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile(
    this.item, {
    required this.period,
    required this.walletId,
  });

  final CategoryShare item;
  final ReportPeriod period;
  final String? walletId;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: IconCircle(icon: item.category.icon, color: item.category.color),
      title: Text(item.category.name),
      subtitle: Text('${(item.share * 100).round()}%'),
      trailing: AmountText(-item.amount, signed: true),
      onTap: () => context.pushNamed(
        Routes.categoryTransactions,
        extra: CategoryTransactionsArgs(
          category: item.category,
          from: period.start,
          to: period.end,
          walletId: walletId,
        ),
      ),
    );
  }
}

class _DayTransactions extends ConsumerWidget {
  const _DayTransactions({required this.day, required this.walletId});

  final String day;
  final String? walletId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = periodTransactionsProvider(day, day, walletId: walletId);
    return ref
        .watch(provider)
        .when(
          loading: () => const Skeleton(height: Spacing.xxl * 2),
          error: (error, _) =>
              ErrorState(error: error, onRetry: () => ref.invalidate(provider)),
          data: (items) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [for (final item in items) TransactionTile(item)],
          ),
        );
  }
}
