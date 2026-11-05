import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/session_provider.dart';
import '../../../core/format/dates.dart';
import '../../../core/notifications/reminder_service.dart';
import '../../../core/router/router.dart';
import '../../dashboard/providers/dashboard_providers.dart';
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
    _reminders = ref.read(reminderServiceProvider)..onTap = _openToday;
    // Izin bisa diubah dari pengaturan HP selagi aplikasi di latar belakang.
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(notificationsEnabledProvider),
    );
    unawaited(_start());
  }

  Future<void> _start() async {
    if (await _reminders.launchedFromNotification()) _openToday();
    await _reminders.requestPermission();
    if (mounted) ref.invalidate(notificationsEnabledProvider);
  }

  void _openToday() {
    if (!mounted) return;
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
    if (dashboard.isLoading || dashboard.hasError || !dashboard.hasValue) return;
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

  @override
  void dispose() {
    _lifecycle.dispose();
    _reminders.onTap = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(dashboardProvider, (_, _) => _syncReminders());
    ref.listen(meProvider, (_, _) => _syncReminders());
    // Mencakup tombol Keluar dan sesi kedaluwarsa.
    ref.listen(sessionProvider, (_, next) {
      if (next.value == false) unawaited(_reminders.cancel());
    });

    final shell = widget.shell;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
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
    );
  }
}
