import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/format/money.dart';
import '../../../../core/theme/tokens.dart';
import '../../data/dashboard_models.dart';

/// Pengeluaran per titik waktu; dipakai Beranda dan Laporan.
class ExpenseBarChart extends StatelessWidget {
  const ExpenseBarChart({
    super.key,
    required this.points,
    required this.barWidth,
    required this.labelOf,
  });

  final List<SeriesPoint> points;
  final double barWidth;

  /// Label sumbu bawah; kosong = tanpa label di titik itu.
  final String Function(SeriesPoint point) labelOf;

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
                  labelOf(points[value.toInt()]),
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
                    width: barWidth,
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
