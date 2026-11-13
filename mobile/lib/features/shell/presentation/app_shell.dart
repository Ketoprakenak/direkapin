import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/session_provider.dart';
import '../../../core/format/dates.dart';
import '../../../core/notifications/reminder_service.dart';
import '../../../core/router/router.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/mascot.dart';
import '../../archive/data/archive_models.dart';
import '../../archive/providers/archive_providers.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../recurring/providers/recurring_providers.dart';
import '../../settings/providers/settings_providers.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  late final ReminderService _reminders;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _reminders = ref.read(reminderServiceProvider)..onTap = _openFrom;
    // Izin bisa diubah dari pengaturan HP selagi aplikasi di latar belakang.
    _lifecycle = AppLifecycleListener(
      onResume: () {
        ref.invalidate(notificationsEnabledProvider);
        ref.invalidate(archivesProvider);
        ref.invalidate(recurringDueProvider);
        ref.invalidate(recurringListProvider);
      },
    );
    unawaited(_start());
  }

  Future<void> _start() async {
    final launch = await _reminders.launchDetails();
    if (launch.launched) _openFrom(launch.payload);
    await _reminders.requestPermission();
    if (mounted) ref.invalidate(notificationsEnabledProvider);
  }

  void _openFrom(String? payload) {
    if (!mounted) return;
    if (payload == archivePayload) {
      ref.read(appRouterProvider).pushNamed(Routes.archives);
      return;
    }
    if (payload == homePayload) {
      ref.read(appRouterProvider).goNamed(Routes.home);
      return;
    }
    ref
        .read(appRouterProvider)
        .pushNamed(
          Routes.day,
          pathParameters: {'date': dateKey(DateTime.now())},
        );
  }

  /// Pasang ulang saat data segar: aplikasi dibuka, catatan berubah, jam diubah.
  void _syncReminders() {
    final dashboard = ref.read(dashboardProvider);
    final me = ref.read(meProvider);
    // Gagal memuat: jadwal lama tetap dipakai.
    if (dashboard.isLoading || dashboard.hasError || !dashboard.hasValue) {
      return;
    }
    if (me.isLoading || me.hasError || !me.hasValue) return;
    unawaited(
      _reminders.sync(
        reminderTime: me.requireValue.reminderTime,
        timezone: me.requireValue.timezone,
        today: dashboard.requireValue.today.date,
        hasEntry: dashboard.requireValue.today.hasEntry,
      ),
    );
  }

  void _syncArchives() {
    final archives = ref.read(archivesProvider);
    final me = ref.read(meProvider);
    // Gagal memuat: jadwal lama tetap dipakai.
    if (archives.isLoading || archives.hasError || !archives.hasValue) return;
    if (me.isLoading || me.hasError || !me.hasValue) return;
    final ready = [
      for (final archive in archives.requireValue)
        if (archive.status == ArchiveStatus.ready)
          (id: archive.id, month: archive.month, createdAt: archive.createdAt),
    ];
    unawaited(_reminders.syncArchives(ready, me.requireValue.timezone));
  }

  void _syncRecurring() {
    final rules = ref.read(recurringListProvider);
    final me = ref.read(meProvider);
    // Gagal memuat: jadwal lama tetap dipakai.
    if (rules.isLoading || rules.hasError || !rules.hasValue) return;
    if (me.isLoading || me.hasError || !me.hasValue) return;
    unawaited(
      _reminders.syncRecurring([
        for (final rule in rules.requireValue)
          if (rule.next case final next?)
            (
              dueDate: next.dueDate,
              label: (rule.note?.trim().isNotEmpty ?? false)
                  ? rule.note!.trim()
                  : rule.category.name,
              amount: rule.amount,
            ),
      ], me.requireValue.timezone),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _reminders.onTap = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(dashboardProvider, (_, _) => _syncReminders());
    ref.listen(meProvider, (_, _) {
      _syncReminders();
      _syncArchives();
      _syncRecurring();
    });
    ref.listen(recurringListProvider, (_, _) => _syncRecurring());
    ref.listen(archivesProvider, (_, _) => _syncArchives());
    // Mencakup tombol Keluar dan sesi kedaluwarsa.
    ref.listen(sessionProvider, (_, next) {
      if (next.value == false) unawaited(_reminders.cancel());
    });

    final shell = widget.shell;
    return Scaffold(
      body: shell,
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          NavigationBar(
            selectedIndex: shell.currentIndex,
            onDestinationSelected: (index) => shell.goBranch(
              index,
              initialLocation: index == shell.currentIndex,
            ),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_rounded),
                label: 'Beranda',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_rounded),
                label: 'Kalender',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_rounded),
                label: 'Laporan',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_rounded),
                label: 'Profil',
              ),
            ],
          ),
          _NavPeekMascot(index: shell.currentIndex, count: 4),
        ],
      ),
    );
  }
}

/// Maskot dekoratif yang melongok dari tepi atas tab aktif; tap tembus.
class _NavPeekMascot extends StatelessWidget {
  const _NavPeekMascot({required this.index, required this.count});

  final int index;
  final int count;

  static const _size = Spacing.xxl;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return AnimatedPositioned(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      top: -Spacing.lg,
      left: width / count * (index + 0.5) - _size / 2,
      width: _size,
      height: _size,
      child: const IgnorePointer(
        child: ExcludeSemantics(
          child: Mascot(
            key: ValueKey('nav-peek-mascot'),
            pose: MascotPose.peek,
            size: _size,
          ),
        ),
      ),
    );
  }
}
