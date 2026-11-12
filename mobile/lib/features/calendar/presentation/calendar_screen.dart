import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/format/dates.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/frame.dart';
import '../../../core/widgets/state_views.dart';
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

    Widget cell(BuildContext context, DateTime date, DateTime _) =>
        CalendarCell(
          day: date.day,
          isToday: isSameDay(date, DateTime.now()),
          data: days[dateKey(date)],
        );

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
              child: TableCalendar<void>(
                locale: 'id_ID',
                firstDay: DateTime.utc(2000),
                lastDay: DateTime.utc(2100),
                focusedDay: _focused,
                startingDayOfWeek: StartingDayOfWeek.monday,
                availableCalendarFormats: const {CalendarFormat.month: 'Bulan'},
                availableGestures: AvailableGestures.horizontalSwipe,
                rowHeight: Spacing.xxl * 2 + Spacing.xs,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle:
                      theme.textTheme.titleMedium ?? const TextStyle(),
                ),
                calendarStyle: const CalendarStyle(outsideDaysVisible: false),
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
