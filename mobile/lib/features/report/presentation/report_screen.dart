import 'dart:io';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_error.dart';
import '../../../core/format/dates.dart';
import '../../../core/format/money.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/app_themes.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/frame.dart';
import '../../../core/widgets/money_widgets.dart';
import '../../../core/widgets/pill_tabs.dart';
import '../../../core/widgets/state_views.dart';
import '../../budget/presentation/budget_screen.dart';
import '../../budget/providers/budget_providers.dart';
import '../../dashboard/data/dashboard_models.dart';
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
  // Custom terpisah dari _anchor: tetap saat pindah ke Mingguan/Bulanan dan kembali.
  DateTimeRange _range = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month),
    end: DateUtils.dateOnly(DateTime.now()),
  );
  String _walletId = _allWallets;
  bool _exporting = false;

  /// Tanggal awal dan akhir (inklusif) periode yang sedang dibuka.
  (DateTime, DateTime) get _period => switch (_type) {
    ReportType.weekly => (
      mondayOf(_anchor),
      mondayOf(_anchor).add(const Duration(days: 6)),
    ),
    ReportType.monthly => (
      DateTime(_anchor.year, _anchor.month),
      DateTime(_anchor.year, _anchor.month + 1, 0),
    ),
    ReportType.range => (_range.start, _range.end),
  };

  Future<void> _export(String? walletId) async {
    final format = await showModalBottomSheet<ExportFormat>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'Export $_label',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart_rounded),
              title: const Text('CSV'),
              subtitle: const Text('Daftar transaksi, buka di Excel/Sheets'),
              onTap: () => Navigator.pop(context, ExportFormat.csv),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded),
              title: const Text('PDF'),
              subtitle: const Text('Ringkasan + daftar transaksi'),
              onTap: () => Navigator.pop(context, ExportFormat.pdf),
            ),
          ],
        ),
      ),
    );
    if (format == null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final (from, to) = _period;
    setState(() => _exporting = true);
    String message;
    try {
      final fileName = await ref
          .read(reportExporterProvider)
          .export(
            from: dateKey(from),
            to: dateKey(to),
            format: format,
            walletId: walletId,
          );
      message = '$fileName tersimpan di Download/Direkapin';
    } on ApiException catch (e) {
      message = e.message;
    } on PlatformException catch (e) {
      message = e.code == 'permission_denied'
          ? 'Izin penyimpanan ditolak. Aktifkan di pengaturan HP.'
          : 'File gagal disimpan. Coba lagi.';
    } on FileSystemException {
      message = 'File gagal disimpan. Coba lagi.';
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  String get _key => switch (_type) {
    ReportType.weekly => dateKey(mondayOf(_anchor)),
    ReportType.monthly => monthKey(_anchor),
    ReportType.range => '${dateKey(_range.start)}_${dateKey(_range.end)}',
  };

  String get _label {
    switch (_type) {
      case ReportType.weekly:
        final monday = mondayOf(_anchor);
        final sunday = DateTime(monday.year, monday.month, monday.day + 6);
        return '${formatShortDate(monday)} – ${formatShortDate(sunday)}';
      case ReportType.monthly:
        return formatMonth(_anchor);
      case ReportType.range:
        return '${formatShortDate(_range.start)} – ${formatShortDate(_range.end)}';
    }
  }

  void _shift(int direction) {
    setState(() {
      final date = _anchor;
      _anchor = switch (_type) {
        ReportType.weekly => DateTime(
          date.year,
          date.month,
          date.day + 7 * direction,
        ),
        // Tanggal 1: tanggal 31 bisa melompati bulan yang lebih pendek.
        ReportType.monthly => DateTime(date.year, date.month + direction),
        // Custom tidak punya panah; rentang diganti lewat pemilih.
        ReportType.range => date,
      };
    });
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateUtils.dateOnly(DateTime.now()),
      initialDateRange: _range,
    );
    if (picked == null || !mounted) return;
    // UTC supaya pergantian jam musim panas tidak menggeser hitungan hari.
    final days = DateTime.utc(picked.end.year, picked.end.month, picked.end.day)
        .difference(
          DateTime.utc(picked.start.year, picked.start.month, picked.start.day),
        )
        .inDays;
    if (days > 365) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rentang maksimal 366 hari')),
      );
      return;
    }
    setState(() => _range = picked);
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
      appBar: AppBar(
        title: const Text('Laporan'),
        actions: [
          IconButton(
            tooltip: 'Export',
            onPressed: _exporting ? null : () => _export(walletId),
            icon: _exporting
                ? const SizedBox.square(
                    dimension: Spacing.lg,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          PillTabs(
            labels: const {
              ReportType.weekly: 'Mingguan',
              ReportType.monthly: 'Bulanan',
              ReportType.range: 'Custom',
            },
            selected: _type,
            onChanged: (type) => setState(() => _type = type),
          ),
          const SizedBox(height: Spacing.sm),
          if (_type == ReportType.range)
            Tooltip(
              message: 'Pilih rentang',
              child: FrameBox(
                padding: EdgeInsets.zero,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      AppStyle.of(context).cardRadius / 2,
                    ),
                    onTap: _pickRange,
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.md),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _label,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          const Icon(Icons.calendar_month_rounded),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                IconButton(
                  tooltip: 'Periode sebelumnya',
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () => _shift(-1),
                ),
                Expanded(
                  child: FrameBox(
                    padding: const EdgeInsets.all(Spacing.md),
                    child: Text(
                      _label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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
          FrameBox(
            child: _WalletFilter(
              wallets: wallets ?? const [],
              selected: walletId ?? _allWallets,
              onChanged: (value) => setState(() => _walletId = value),
            ),
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

/// Tab kapsul berframe dalam; tab aktif = blok penuh warna teks tema.
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
      // Garis input dimatikan: bingkainya dari FrameBox.
      decoration: const InputDecoration(
        labelText: 'Dompet',
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
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

    final colors = AppColors.of(context);
    // Bulanan dan Custom: grafik garis + donut. Mingguan: daftar kategori.
    final charts = type != ReportType.weekly;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _Total('Pemasukan', totals.income, colors.incomeTint),
            ),
            Expanded(
              child: _Total('Pengeluaran', -totals.expense, colors.expenseTint),
            ),
            Expanded(
              child: _Total('Selisih', totals.net, colors.importantTint),
            ),
          ],
        ),
        if (report.comparison case final comparison?) ...[
          const SizedBox(height: Spacing.md),
          Text(_comparisonText(comparison), style: theme.textTheme.bodyMedium),
        ],
        if (type == ReportType.monthly) ...[
          const SizedBox(height: Spacing.md),
          OutlinedButton.icon(
            onPressed: () => context.pushNamed(
              Routes.wrapped,
              extra: report.period.start.substring(0, 7),
            ),
            icon: const Icon(Icons.auto_awesome_rounded),
            label: Text(
              'Lihat rekap ${formatMonth(DateTime.parse(report.period.start))}',
            ),
          ),
        ],
        if (totals.transactionCount == 0)
          const EmptyState(message: 'Belum ada transaksi di periode ini.')
        else ...[
          // Mingguan tanpa grafik batang: sudah ada grafik 7 hari di Beranda.
          if (report.series.isNotEmpty && charts) ...[
            section('Pengeluaran per hari'),
            FrameCard(
              child: _DailyLineChart(
                report.series,
                range: type == ReportType.range,
              ),
            ),
          ],
          if (report.byCategory.isNotEmpty) ...[
            // Bulanan/Custom: donut semua / top 3, judul + toggle di dalamnya.
            // Mingguan: daftar.
            if (!charts) section('Pengeluaran per kategori'),
            if (charts)
              _MonthlyCategories(
                report.byCategory,
                period: report.period,
                walletId: walletId,
              )
            else
              for (final item in report.byCategory)
                _CategoryTile(item, period: report.period, walletId: walletId),
          ],
        ],
        // Tetap tampil di bulan tanpa transaksi, supaya budget bisa diatur dari awal.
        if (type == ReportType.monthly) ...[
          section('Budget'),
          _BudgetSection(month: report.period.start.substring(0, 7)),
        ],
      ],
    );
  }

  String _comparisonText(ReportComparison comparison) {
    final range = type == ReportType.range;
    final before = range ? 'periode sebelumnya' : 'bulan lalu';
    final pct = comparison.changePct;
    if (pct == null) {
      return range
          ? 'Periode sebelumnya belum ada pengeluaran.'
          : 'Bulan lalu belum ada pengeluaran.';
    }
    final previous = formatRupiah(comparison.previousExpense);
    final rounded = pct.abs().round();
    if (rounded == 0) return 'Pengeluaran sama dengan $before ($previous).';
    final direction = pct > 0 ? 'naik' : 'turun';
    return 'Pengeluaran $direction $rounded% dari $before ($previous).';
  }
}

/// Apakah titik [index] (0..[last]) diberi label di sumbu-x rentang Custom.
@visibleForTesting
bool showRangeLabel(int index, int last) {
  final step = max(1, (last / 5).ceil());
  return index == last || (index % step == 0 && last - index >= step);
}

/// Tren pengeluaran harian: garis lewat semua tanggal (hari kosong = 0),
/// titik hanya di tanggal yang ada pengeluarannya, tap untuk nominal.
class _DailyLineChart extends StatelessWidget {
  const _DailyLineChart(this.points, {required this.range});

  final List<SeriesPoint> points;

  /// Rentang Custom: label `4 Nov` secukupnya; bulanan: tanggal tiap 5 hari.
  final bool range;

  String _axisLabel(int index) {
    final last = points.length - 1;
    if (index < 0 || index > last) return '';
    final date = DateTime.parse(points[index].label);
    if (!range) {
      return date.day == 1 || date.day % 5 == 0 ? '${date.day}' : '';
    }
    // Maks. ±6 label; titik pertama dan terakhir selalu tampil, label antara
    // yang terlalu dekat ke titik terakhir dilewati supaya tidak bertumpuk.
    return showRangeLabel(index, last) ? formatShortDate(date) : '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expense = AppColors.of(context).expense;
    final highest = points.fold(0, (peak, point) => max(peak, point.expense));
    final label = theme.textTheme.labelSmall;
    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minX: 1,
          maxX: points.length.toDouble(),
          minY: 0,
          maxY: max(highest, 1) * 1.25,
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: theme.colorScheme.outlineVariant, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => value == meta.max
                    // Puncak sumbu = nilai tertinggi × 1,25, angkanya tidak bulat.
                    ? const SizedBox.shrink()
                    : Text(formatCompact(value.toInt()), style: label),
              ),
            ),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                // Tidak tiap hari: 31 label tidak muat dalam satu baris.
                getTitlesWidget: (value, meta) =>
                    Text(_axisLabel(value.toInt() - 1), style: label),
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => [
                for (final spot in spots)
                  LineTooltipItem(
                    formatCompact(spot.y.toInt()),
                    (label ?? const TextStyle()).copyWith(color: expense),
                  ),
              ],
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              // x = urutan titik (1..n), supaya rentang lintas bulan tetap urut.
              spots: [
                for (final (index, point) in points.indexed)
                  FlSpot(index + 1, point.expense.toDouble()),
              ],
              isCurved: true,
              // Lengkungan tidak boleh turun di bawah nol di hari kosong.
              preventCurveOverShooting: true,
              color: expense,
              barWidth: 2,
              dotData: FlDotData(
                // Titik hanya di tanggal yang ada pengeluarannya.
                checkToShowDot: (spot, _) => spot.y > 0,
                getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                  radius: 2.5,
                  color: theme.colorScheme.surface,
                  strokeColor: expense,
                  strokeWidth: 1.5,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: expense.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kotak ringkasan berframe luar. Teks `onSurface`, bukan warna masuk/keluar:
/// kontras di atas latar muda hanya dijamin untuk `onSurface`.
class _Total extends StatelessWidget {
  const _Total(this.label, this.amount, this.tint);

  final String label;
  final int amount;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = theme.colorScheme.onSurface;
    return FrameCard(
      color: tint,
      padding: const EdgeInsets.all(Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(color: ink),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatRupiah(amount, showPlus: true),
              style: theme.textTheme.titleSmall?.copyWith(color: ink),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ringkasan budget bulan itu (FIN-12); kelola lengkap di layar Budget.
class _BudgetSection extends ConsumerWidget {
  const _BudgetSection({required this.month});

  final String month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = budgetsProvider(month);
    void open() => context.pushNamed(Routes.budgets, extra: month);
    return ref
        .watch(provider)
        .when(
          loading: () => const Skeleton(height: Spacing.xxl * 3),
          error: (error, _) =>
              ErrorState(error: error, onRetry: () => ref.invalidate(provider)),
          data: (budgets) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (budgets.isEmpty)
                Text(
                  'Belum ada budget. Atur batas pengeluaran untuk kategori yang mau dijaga.',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                for (final budget in budgets) ...[
                  BudgetCard(budget, onTap: open),
                  const SizedBox(height: Spacing.sm),
                ],
              const SizedBox(height: Spacing.sm),
              OutlinedButton.icon(
                onPressed: open,
                icon: Icon(
                  budgets.isEmpty ? Icons.add_rounded : Icons.tune_rounded,
                ),
                label: Text(budgets.isEmpty ? 'Atur budget' : 'Kelola budget'),
              ),
            ],
          ),
        );
  }
}

/// Kategori bulanan/Custom: donut semua kategori atau 3 terbesar. Tombol kecil di
/// kanan judul menampilkan mode yang akan dituju.
class _MonthlyCategories extends StatefulWidget {
  const _MonthlyCategories(
    this.items, {
    required this.period,
    required this.walletId,
  });

  final List<CategoryShare> items;
  final ReportPeriod period;
  final String? walletId;

  @override
  State<_MonthlyCategories> createState() => _MonthlyCategoriesState();
}

class _MonthlyCategoriesState extends State<_MonthlyCategories> {
  bool _top3 = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: Spacing.xl, bottom: Spacing.sm),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Pengeluaran per kategori',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              // Toggle berframe dalam.
              Semantics(
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _top3 = !_top3),
                  // Bingkai tetap kecil, area sentuh setinggi target minimum.
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: kMinInteractiveDimension,
                    ),
                    alignment: Alignment.center,
                    child: FrameBox(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.swap_horiz_rounded),
                          const SizedBox(width: Spacing.xs),
                          Text(
                            _top3 ? 'Semua' : 'Top 3',
                            style: theme.textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        FrameCard(
          child: _CategoryDonut(
            // byCategory dari server sudah urut nominal terbesar.
            _top3 ? widget.items.take(3).toList() : widget.items,
            // Key baru tiap mode supaya pilihan segmen kembali ke yang terbesar.
            key: ValueKey(_top3),
            period: widget.period,
            walletId: widget.walletId,
          ),
        ),
      ],
    );
  }
}

class _CategoryDonut extends StatefulWidget {
  const _CategoryDonut(
    this.items, {
    super.key,
    required this.period,
    required this.walletId,
  });

  final List<CategoryShare> items;
  final ReportPeriod period;
  final String? walletId;

  @override
  State<_CategoryDonut> createState() => _CategoryDonutState();
}

class _CategoryDonutState extends State<_CategoryDonut> {
  static const _hole = Spacing.xxl + Spacing.sm;
  static const _ring = Spacing.lg + Spacing.xs;
  static const _size = (_hole + _ring + Spacing.xs) * 2;

  // Kategori terbesar terpilih dari awal, supaya kartu kanan tidak kosong.
  int _selected = 0;

  void _onTouch(FlTouchEvent event, PieTouchResponse? response) {
    if (event is! FlTapUpEvent) return;
    final index = response?.touchedSection?.touchedSectionIndex ?? -1;
    if (index >= 0) setState(() => _selected = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = widget.items;
    final summary = [
      for (final item in items)
        '${item.category.name} ${(item.share * 100).round()}%',
    ].join(', ');
    final total = items.fold(0, (sum, item) => sum + item.amount);
    final selected = _selected.clamp(0, items.length - 1);
    return Row(
      children: [
        SizedBox.square(
          dimension: _size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Semantics(
                label: 'Grafik pengeluaran per kategori: $summary',
                excludeSemantics: true,
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: _hole,
                    sectionsSpace: Spacing.xs / 2,
                    pieTouchData: PieTouchData(touchCallback: _onTouch),
                    sections: [
                      for (final (index, item) in items.indexed)
                        PieChartSectionData(
                          value: item.amount.toDouble(),
                          color: colorFromHex(item.category.color),
                          radius: index == selected
                              ? _ring + Spacing.xs
                              : _ring,
                          showTitle: false,
                        ),
                    ],
                  ),
                ),
              ),
              // Total di lubang tengah; tap tembus ke donut.
              IgnorePointer(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Total', style: theme.textTheme.labelSmall),
                    Text(
                      formatCompact(total),
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: _ShareBubble(
            items[selected],
            period: widget.period,
            walletId: widget.walletId,
            position: '${selected + 1}/${items.length}',
            // Berputar; kategori kecil yang potongannya tipis tetap bisa dipilih.
            onStep: items.length < 2
                ? null
                : (delta) => setState(
                    () => _selected = (selected + delta) % items.length,
                  ),
          ),
        ),
      ],
    );
  }
}

class _ShareBubble extends StatelessWidget {
  const _ShareBubble(
    this.item, {
    required this.period,
    required this.walletId,
    required this.position,
    required this.onStep,
  });

  final CategoryShare item;
  final ReportPeriod period;
  final String? walletId;

  /// Urutan kategori terpilih, mis. `2/5`.
  final String position;

  /// Pindah kategori -1/+1; null jika hanya satu kategori.
  final void Function(int delta)? onStep;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.md,
          Spacing.sm,
          Spacing.md,
          0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge,
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AmountText(-item.amount, signed: true),
            ),
            Text(
              '${(item.share * 100).round()}% pengeluaran',
              style: theme.textTheme.labelSmall,
            ),
            TextButton(
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              onPressed: () => context.pushNamed(
                Routes.categoryTransactions,
                extra: CategoryTransactionsArgs(
                  category: item.category,
                  from: period.start,
                  to: period.end,
                  walletId: walletId,
                ),
              ),
              child: const Text('Lihat detail'),
            ),
            if (onStep case final step?)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    tooltip: 'Kategori sebelumnya',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: () => step(-1),
                  ),
                  Text(position, style: theme.textTheme.labelSmall),
                  IconButton(
                    tooltip: 'Kategori berikutnya',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: () => step(1),
                  ),
                ],
              ),
          ],
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
