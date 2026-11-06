import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../format/dates.dart';

part 'reminder_service.g.dart';

const _firstReminderId = 1000;
const _reminderDays = 30;
const _firstMonthlyId = 1100;
const _monthlyCount = 3;
const _firstArchiveReminderId = 1200;
const _maxArchiveReminders = 20;
const _firstArchiveNoticeId = 1300;
const _seenArchivesKey = 'archivesSeen';
const _archiveLifetimeDays = 30;

/// Isi `payload` notifikasi yang membuka layar Arsip.
const archivePayload = 'archive';

const _dailyDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    'daily_reminder',
    'Pengingat harian',
    importance: Importance.high,
    priority: Priority.high,
  ),
);
const _archiveDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    'archive_reminder',
    'Arsip foto',
    importance: Importance.high,
    priority: Priority.high,
  ),
);

/// Arsip `READY` yang perlu diingatkan.
typedef ReadyArchive = ({String id, String month, DateTime createdAt});

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

/// Pengingat umum cek arsip: tanggal 1 pukul 09.00, [_monthlyCount] bulan ke depan.
List<tz.TZDateTime> monthlyArchiveDates(tz.TZDateTime now) {
  final dates = [
    for (var offset = 0; offset <= _monthlyCount; offset++)
      tz.TZDateTime(now.location, now.year, now.month + offset, 1, 9),
  ];
  return dates.where((date) => date.isAfter(now)).take(_monthlyCount).toList();
}

/// Hari ke-7 dan ke-25 setelah arsip dibuat, pukul 09.00; yang sudah lewat dilewati.
/// [createdAt] dibaca di zona waktu [now].
List<({tz.TZDateTime date, int daysLeft})> archiveReminderDates(
  DateTime createdAt,
  tz.TZDateTime now,
) {
  final local = tz.TZDateTime.from(createdAt, now.location);
  return [
    for (final day in const [7, 25])
      (
        date: tz.TZDateTime(
          now.location,
          local.year,
          local.month,
          local.day + day,
          9,
        ),
        daysLeft: _archiveLifetimeDays - day,
      ),
  ].where((item) => item.date.isAfter(now)).toList();
}

/// Pengingat lokal: harian (ENG-01) dan arsip (ARC-03, ARC-04). Tanpa push server (D-21).
class ReminderService {
  final _plugin = FlutterLocalNotificationsPlugin();
  static const _storage = FlutterSecureStorage();

  /// Dipanggil saat notifikasi di-tap ketika aplikasi sedang berjalan.
  void Function(String? payload)? onTap;

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
      onDidReceiveNotificationResponse: (response) =>
          onTap?.call(response.payload),
    );
  }

  Future<void> _enqueue(Future<void> Function() task) {
    return _queue = _queue.then((_) => task()).catchError((Object error) {
      // Jadwal lama tetap berlaku; pengingat tidak boleh mengganggu aplikasi.
      debugPrint('Pengingat gagal: $error');
    });
  }

  /// `launched` true sekali saja jika aplikasi dibuka dari notifikasi.
  Future<({bool launched, String? payload})> launchDetails() async {
    await _ready;
    if (_launchHandled) return (launched: false, payload: null);
    _launchHandled = true;
    final details = await _plugin.getNotificationAppLaunchDetails();
    return (
      launched: details?.didNotificationLaunchApp ?? false,
      payload: details?.notificationResponse?.payload,
    );
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
    final mode = await _scheduleMode();
    await _cancelReminders();
    for (final (index, date) in dates.indexed) {
      await _plugin.zonedSchedule(
        id: _firstReminderId + index,
        title: 'Direkapin',
        body: 'Hari ini udah dicatat belum? Cuma butuh 15 detik.',
        scheduledDate: date,
        notificationDetails: _dailyDetails,
        androidScheduleMode: mode,
      );
    }
    final months = monthlyArchiveDates(
      tz.TZDateTime.now(tz.getLocation(timezone)),
    );
    for (final (index, date) in months.indexed) {
      await _plugin.zonedSchedule(
        id: _firstMonthlyId + index,
        title: 'Direkapin',
        body: 'Cek arsip foto kamu, siapa tahu ada yang baru.',
        scheduledDate: date,
        notificationDetails: _archiveDetails,
        androidScheduleMode: mode,
        payload: archivePayload,
      );
    }
  });

  /// Arsip baru diberi tahu sekali, lalu pengingat hari ke-7 dan ke-25 dipasang ulang.
  /// Arsip yang sudah di-download tidak ada di [ready], jadi pengingatnya ikut hilang.
  Future<void> syncArchives(List<ReadyArchive> ready, String timezone) =>
      _enqueue(() async {
        await _ready;
        final seen = (await _storage.read(key: _seenArchivesKey))?.split(',') ?? [];
        for (final archive in ready.where((a) => !seen.contains(a.id))) {
          final monthNumber = int.parse(archive.month.substring(5));
          await _plugin.show(
            id: _firstArchiveNoticeId + monthNumber,
            title: 'Direkapin',
            body: 'Arsip ${_monthName(archive.month)} siap di-download.',
            notificationDetails: _archiveDetails,
            payload: archivePayload,
          );
        }
        await _storage.write(
          key: _seenArchivesKey,
          value: ready.map((a) => a.id).join(','),
        );

        final now = tz.TZDateTime.now(tz.getLocation(timezone));
        final mode = await _scheduleMode();
        await _cancelArchiveReminders();
        var id = _firstArchiveReminderId;
        for (final archive in ready) {
          for (final item in archiveReminderDates(archive.createdAt, now)) {
            if (id >= _firstArchiveReminderId + _maxArchiveReminders) return;
            await _plugin.zonedSchedule(
              id: id++,
              title: 'Direkapin',
              body:
                  'Arsip ${_monthName(archive.month)} belum di-download. '
                  'Foto aslinya dihapus ${item.daysLeft} hari lagi.',
              scheduledDate: item.date,
              notificationDetails: _archiveDetails,
              androidScheduleMode: mode,
              payload: archivePayload,
            );
          }
        }
      });

  Future<void> cancel() => _enqueue(() async {
    await _ready;
    await _cancelReminders();
    await _cancelArchiveReminders();
    for (var offset = 0; offset < _monthlyCount; offset++) {
      await _plugin.cancel(id: _firstMonthlyId + offset);
    }
    await _storage.delete(key: _seenArchivesKey);
  });

  String _monthName(String month) => formatMonth(DateTime.parse('$month-01'));

  /// Izin exact bisa dicabut user di Android 12.
  Future<AndroidScheduleMode> _scheduleMode() async =>
      await _android?.canScheduleExactNotifications() ?? false
      ? AndroidScheduleMode.exactAllowWhileIdle
      : AndroidScheduleMode.inexactAllowWhileIdle;

  Future<void> _cancelArchiveReminders() async {
    for (var offset = 0; offset < _maxArchiveReminders; offset++) {
      await _plugin.cancel(id: _firstArchiveReminderId + offset);
    }
  }

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
