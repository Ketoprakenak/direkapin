import 'dart:math';

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
import '../../transaction/presentation/widgets/add_sheet.dart';
import '../../wallet/data/wallet_models.dart';
import '../data/dashboard_models.dart';
import '../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Beranda')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddSheet(context),
        tooltip: 'Tambah',
        child: const Icon(Icons.add_rounded),
      ),
      body: dashboard.when(
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.refresh(dashboardProvider.future),
          child: _DashboardBody(data),
        ),
        error: (error, _) => ErrorState(
          error: error,
          onRetry: () => ref.invalidate(dashboardProvider),
        ),
        loading: () => const _DashboardSkeleton(),
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
        const SizedBox(height: Spacing.md),
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: data.wallets.length,
            separatorBuilder: (_, _) => const SizedBox(width: Spacing.md),
            itemBuilder: (context, index) => _WalletCard(data.wallets[index]),
          ),
        ),
        const SizedBox(height: Spacing.xl),
        if (data.streak.current > 0) ...[
          Row(
            children: [
              Icon(Icons.local_fire_department_rounded, color: colors.important),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  '${data.streak.current} hari berturut-turut mencatat',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xl),
        ],
        Text('Pengeluaran 7 hari', style: theme.textTheme.titleMedium),
        const SizedBox(height: Spacing.md),
        _WeekChart(data.last7Days),
        const SizedBox(height: Spacing.xl),
        Text('Hari ini', style: theme.textTheme.titleMedium),
        const SizedBox(height: Spacing.sm),
        if (!data.today.hasEntry)
          const EmptyState(
            message: 'Belum ada catatan hari ini. Mulai dari pengeluaran pertamamu.',
          )
        else ...[
          Row(
            children: [
              Expanded(
                child: Text('Keluar hari ini', style: theme.textTheme.bodyLarge),
              ),
              AmountText(-data.today.expense),
            ],
          ),
          for (final activity in data.today.activities)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                activity.isImportant ? Icons.star_rounded : Icons.event_note_rounded,
                color: activity.isImportant ? colors.important : colors.activity,
              ),
              title: Text(activity.title),
              subtitle: Text(formatActivityTime(activity.time)),
              onTap: () =>
                  context.pushNamed(Routes.activityDetail, extra: activity),
            ),
        ],
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard(this.data);

  final Dashboard data;

  @override
  Widget build(BuildContext context) {
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

    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(Radii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total saldo', style: theme.textTheme.bodyMedium),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AmountText(data.totalBalance, large: true),
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              monthColumn('Masuk bulan ini', data.month.income, colors.income),
              monthColumn('Keluar bulan ini', data.month.expense, colors.expense),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard(this.wallet);

  final Wallet wallet;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.pushNamed(Routes.wallets),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconCircle(icon: wallet.icon, color: wallet.color),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wallet.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: AmountText(wallet.balance),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekChart extends StatelessWidget {
  const _WeekChart(this.points);

  final List<SeriesPoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expense = AppColors.of(context).expense;
    final highest = points.fold(0, (peak, point) => max(peak, point.expense));
    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          // Nilai 1 menjaga grafik tetap valid saat semua hari kosong.
          maxY: max(highest, 1) * 1.25,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(
                  formatWeekday(DateTime.parse(points[value.toInt()].label)),
                  style: theme.textTheme.labelSmall,
                ),
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                formatCompact(rod.toY.toInt()),
                theme.textTheme.labelSmall ?? const TextStyle(),
              ),
            ),
          ),
          barGroups: [
            for (final (index, point) in points.indexed)
              BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: point.expense.toDouble(),
                    color: expense,
                    width: Spacing.lg,
                    borderRadius: BorderRadius.circular(Radii.sm / 2),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
