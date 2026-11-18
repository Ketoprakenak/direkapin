import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/format/dates.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/app_themes.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/frame.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/data/auth_models.dart';
import '../../settings/providers/settings_providers.dart';
import '../../transaction/presentation/widgets/add_sheet.dart';
import '../providers/calendar_providers.dart';
import 'widgets/calendar_cell.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focused = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = calendarMonthProvider(monthKey(_focused));
    final month = ref.watch(provider);
    final days = {for (final day in month.value ?? const []) day.date: day};
    final maxExpense = days.values.fold(
      0,
      (m, d) => d.expense > m ? d.expense : m,
    );
    // Profil belum/gagal dimuat: pakai Otomatis.
    final scale = ref.watch(meProvider).value?.heatmap;
    int? level(int expense) => scale?.mode == HeatmapMode.fixed
        ? fixedHeatLevel(expense, scale!.thresholds)
        : heatLevel(expense, maxExpense);

    Widget cell(BuildContext context, DateTime date, DateTime _) {
      final data = days[dateKey(date)];
      return CalendarCell(
        day: date.day,
        isToday: isSameDay(date, DateTime.now()),
        data: data,
        heat: level(data?.expense ?? 0),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Kalender')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah',
        onPressed: () => showAddSheet(context),
        child: const Icon(Icons.add_rounded),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(provider.future),
        child: ListView(
          padding: const EdgeInsets.all(Spacing.lg),
          children: [
            FrameCard(
              child: Column(
                children: [
                  TableCalendar<void>(
                    locale: 'id_ID',
                    firstDay: DateTime.utc(2000),
                    lastDay: DateTime.utc(2100),
                    focusedDay: _focused,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Bulan',
                    },
                    availableGestures: AvailableGestures.horizontalSwipe,
                    rowHeight: Spacing.xxl * 2 + Spacing.xs,
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle:
                          theme.textTheme.titleMedium ?? const TextStyle(),
                    ),
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: cell,
                      todayBuilder: cell,
                      selectedBuilder: cell,
                    ),
                    onPageChanged: (date) => setState(() => _focused = date),
                    onDaySelected: (date, _) => context.pushNamed(
                      Routes.day,
                      pathParameters: {'date': dateKey(date)},
                    ),
                  ),
                  const _Legend(),
                ],
              ),
            ),
            if (month.isLoading)
              const LinearProgressIndicator()
            else if (month.hasError)
              ErrorState(
                error: month.error!,
                onRetry: () => ref.invalidate(provider),
              )
            else if (days.isEmpty)
              const EmptyState(
                message: 'Bulan ini masih kosong. Yuk, catat yang pertama.',
              ),
          ],
        ),
      ),
    );
  }
}

/// Keterangan warna heatmap di bawah grid.
class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final style = AppStyle.of(context);
    final label = Theme.of(context).textTheme.labelSmall
        ?.copyWith(color: colors.textSecondary);
    Widget swatch(Color color) => Container(
      width: Spacing.lg + Spacing.xs,
      height: Spacing.lg,
      margin: const EdgeInsets.symmetric(horizontal: Spacing.xs / 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(style.dateRadius / 2),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Hemat', style: label),
          const SizedBox(width: Spacing.xs),
          for (final color in colors.heatmap) swatch(color),
          const SizedBox(width: Spacing.xs),
          Text('Boros', style: label),
        ],
      ),
    );
  }
}
