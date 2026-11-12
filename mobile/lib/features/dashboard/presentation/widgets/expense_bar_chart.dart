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
    this.showAxis = false,
  });

  final List<SeriesPoint> points;
  final double barWidth;

  /// Label sumbu bawah; kosong = tanpa label di titik itu.
  final String Function(SeriesPoint point) labelOf;

  /// Sumbu nominal ringkas di kiri + garis bantu horizontal.
  final bool showAxis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expense = AppColors.of(context).expense;
    final highest = points.fold(0, (peak, point) => max(peak, point.expense));
    // Semua hari kosong: sumbu tanpa arti, jadi tidak ditampilkan.
    final axis = showAxis && highest > 0;
    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          // Nilai 1 menjaga grafik tetap valid saat semua hari kosong.
          maxY: max(highest, 1) * 1.25,
          gridData: FlGridData(
            show: axis,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: theme.colorScheme.outlineVariant, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: axis,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => value == meta.max
                    // Puncak sumbu = nilai tertinggi × 1,25, angkanya tidak bulat.
                    ? const SizedBox.shrink()
                    : Text(
                        formatCompact(value.toInt()),
                        style: theme.textTheme.labelSmall,
                      ),
              ),
            ),
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
