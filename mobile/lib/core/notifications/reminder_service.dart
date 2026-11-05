import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../format/dates.dart';

part 'reminder_service.g.dart';

const _firstReminderId = 1000;
const _reminderDays = 30;

/// Waktu pengingat [_reminderDays] hari mulai hari ini. Yang sudah lewat dilewati,
/// begitu juga [today] (`YYYY-MM-DD`) jika sudah ada catatan.
List<tz.TZDateTime> reminderDates({
  required tz.TZDateTime now,
  required String reminderTime,
  required String today,
  required bool hasEntry,
}) {
  final [hour, minute] = reminderTime.split(':').map(int.parse).toList();
  return [
    for (var offset = 0; offset < _reminderDays; offset++)
      tz.TZDateTime(
        now.location,
        now.year,
        now.month,
        now.day + offset,
        hour,
        minute,
      ),
  ].where((date) {
    return date.isAfter(now) && !(hasEntry && dateKey(date) == today);
  }).toList();
}

/// Pengingat harian lokal (ENG-01, D-21).
class ReminderService {
  final _plugin = FlutterLocalNotificationsPlugin();

  /// Dipanggil saat notifikasi di-tap ketika aplikasi sedang berjalan.
  void Function()? onTap;

  var _launchHandled = false;
  late final Future<void> _ready = _init();

  // Berurutan: sync lama yang selesai belakangan tidak boleh menimpa yang baru.
  Future<void> _queue = Future.value();

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  Future<void> _init() async {
    tz_data.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (_) => onTap?.call(),
    );
  }

  Future<void> _enqueue(Future<void> Function() task) {
    return _queue = _queue.then((_) => task()).catchError((Object error) {
      // Jadwal lama tetap berlaku; pengingat tidak boleh mengganggu aplikasi.
      debugPrint('Pengingat gagal: $error');
    });
  }

  /// `true` sekali saja jika aplikasi dibuka dari notifikasi.
  Future<bool> launchedFromNotification() async {
    await _ready;
    if (_launchHandled) return false;
    _launchHandled = true;
    final details = await _plugin.getNotificationAppLaunchDetails();
    return details?.didNotificationLaunchApp ?? false;
  }

  /// Android 13 ke atas; versi lebih lama sudah diizinkan sejak dipasang.
  Future<void> requestPermission() async {
    await _ready;
    await _android?.requestNotificationsPermission();
  }

  Future<bool> notificationsEnabled() async {
    await _ready;
    return await _android?.areNotificationsEnabled() ?? true;
  }

  Future<void> sync({
    required String reminderTime,
    required String timezone,
    required String today,
    required bool hasEntry,
  }) => _enqueue(() async {
    await _ready;
    final dates = reminderDates(
      now: tz.TZDateTime.now(tz.getLocation(timezone)),
      reminderTime: reminderTime,
      today: today,
      hasEntry: hasEntry,
    );
    // Izin exact bisa dicabut user di Android 12.
    final exact = await _android?.canScheduleExactNotifications() ?? false;
    await _cancelReminders();
    for (final (index, date) in dates.indexed) {
      await _plugin.zonedSchedule(
        id: _firstReminderId + index,
        title: 'Direkapin',
        body: 'Hari ini udah dicatat belum? Cuma butuh 15 detik.',
        scheduledDate: date,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder',
            'Pengingat harian',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  });

  Future<void> cancel() => _enqueue(() async {
    await _ready;
    await _cancelReminders();
  });

  Future<void> _cancelReminders() async {
    for (var offset = 0; offset < _reminderDays; offset++) {
      await _plugin.cancel(id: _firstReminderId + offset);
    }
  }
}

@Riverpod(keepAlive: true)
ReminderService reminderService(Ref ref) => ReminderService();

@riverpod
Future<bool> notificationsEnabled(Ref ref) =>
    ref.watch(reminderServiceProvider).notificationsEnabled();
