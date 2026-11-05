import 'package:direkapin/core/auth/session_provider.dart';
import 'package:direkapin/core/format/dates.dart';
import 'package:direkapin/core/notifications/reminder_service.dart';
import 'package:direkapin/core/router/router.dart';
import 'package:direkapin/core/update/app_update.dart';
import 'package:direkapin/features/dashboard/providers/dashboard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../helpers/fake_server.dart';

const _me = {
  'id': 'u1',
  'name': 'Desta',
  'email': 'd@x.com',
  'timezone': 'Asia/Jakarta',
  'reminderTime': '21:00',
  'createdAt': '2026-11-01T00:00:00.000Z',
};

String _today() => dateKey(DateTime.now());

FakeServer _server({bool hasEntry = false, Map<String, Object>? version}) =>
    FakeServer({
      '/me': _me,
      '/dashboard': dashboardJson(hasEntry: hasEntry),
      '/version': ?version,
    });

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
    return initializeDateFormatting('id_ID');
  });

  group('reminderDates', () {
    late tz.Location jakarta;
    setUp(() => jakarta = tz.getLocation('Asia/Jakarta'));

    List<tz.TZDateTime> dates(
      int hour, {
      bool hasEntry = false,
      String today = '2026-11-04',
    }) => reminderDates(
      now: tz.TZDateTime(jakarta, 2026, 11, 4, hour),
      reminderTime: '21:30',
      today: today,
      hasEntry: hasEntry,
    );

    test('belum ada catatan: 30 hari mulai hari ini, lintas bulan', () {
      final result = dates(8);
      expect(result, hasLength(30));
      expect(result.first, tz.TZDateTime(jakarta, 2026, 11, 4, 21, 30));
      expect(result.last, tz.TZDateTime(jakarta, 2026, 12, 3, 21, 30));
    });

    test('sudah ada catatan: mulai besok', () {
      final result = dates(8, hasEntry: true);
      expect(result, hasLength(29));
      expect(result.first, tz.TZDateTime(jakarta, 2026, 11, 5, 21, 30));
    });

    test('jam sudah lewat: mulai besok', () {
      expect(
        dates(22).first,
        tz.TZDateTime(jakarta, 2026, 11, 5, 21, 30),
      );
    });

    test('hasEntry dari tanggal lama tidak melewati hari ini', () {
      final result = dates(8, hasEntry: true, today: '2026-11-03');
      expect(result.first, tz.TZDateTime(jakarta, 2026, 11, 4, 21, 30));
    });
  });

  test('isNewerVersion membandingkan angka, bukan teks', () {
    expect(isNewerVersion('1.10.0', '1.9.0'), isTrue);
    expect(isNewerVersion('1.0.0', '0.1.0'), isTrue);
    expect(isNewerVersion('1.0.0', '1.0.0'), isFalse);
    expect(isNewerVersion('0.9.0', '1.0.0'), isFalse);
    expect(isNewerVersion('1.0.1', '1.0.0+7'), isTrue);
    expect(isNewerVersion('baru', '1.0.0'), isFalse);
    expect(isNewerVersion('1.0', '1.0.0'), isFalse);
  });

  group('jadwal pengingat', () {
    testWidgets('dipasang saat dibuka, memakai data server', (tester) async {
      final reminders = FakeReminderService();
      await pumpRoutedApp(
        tester,
        _server(hasEntry: true),
        routeName: Routes.profile,
        reminders: reminders,
      );

      expect(reminders.syncs.last, (
        reminderTime: '21:00',
        timezone: 'Asia/Jakarta',
        today: '2026-11-04',
        hasEntry: true,
      ));
    });

    testWidgets('dipasang ulang setelah catatan berubah', (tester) async {
      final reminders = FakeReminderService();
      final server = _server();
      await pumpRoutedApp(
        tester,
        server,
        routeName: Routes.profile,
        reminders: reminders,
      );
      expect(reminders.syncs.last.hasEntry, isFalse);

      server.responses['/dashboard'] = dashboardJson(hasEntry: true);
      ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      ).invalidate(dashboardProvider);
      await tester.pumpAndSettle();

      expect(reminders.syncs.last.hasEntry, isTrue);
    });

    testWidgets('dashboard gagal: jadwal lama tidak disentuh', (tester) async {
      final reminders = FakeReminderService();
      await pumpRoutedApp(
        tester,
        FakeServer({'/me': _me, '/dashboard': 500}),
        routeName: Routes.profile,
        reminders: reminders,
      );
      expect(reminders.syncs, isEmpty);
      expect(reminders.cancelled, 0);
    });

    testWidgets('keluar membatalkan jadwal', (tester) async {
      final reminders = FakeReminderService();
      await pumpRoutedApp(
        tester,
        _server(),
        routeName: Routes.profile,
        reminders: reminders,
      );

      ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      ).read(sessionProvider.notifier).markLoggedOut();
      await tester.pumpAndSettle();

      expect(reminders.cancelled, 1);
    });

    testWidgets('dibuka dari notifikasi: masuk Halaman Hari hari ini', (
      tester,
    ) async {
      await pumpRoutedApp(
        tester,
        _server(),
        routeName: null,
        reminders: FakeReminderService()..launched = true,
      );
      final router = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      ).read(appRouterProvider);
      expect(router.state.uri.path, '/hari/${_today()}');
    });

    testWidgets('tap notifikasi saat aplikasi berjalan membuka Halaman Hari', (
      tester,
    ) async {
      final reminders = FakeReminderService();
      await pumpRoutedApp(
        tester,
        _server(),
        routeName: null,
        reminders: reminders,
      );

      reminders.onTap!();
      await tester.pumpAndSettle();

      final router = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      ).read(appRouterProvider);
      expect(router.state.uri.path, '/hari/${_today()}');
    });
  });

  group('Jam pengingat di Profil', () {
    testWidgets('ubah jam mengirim PATCH lalu memasang ulang jadwal', (
      tester,
    ) async {
      final reminders = FakeReminderService();
      final server = _server();
      await pumpRoutedApp(
        tester,
        server,
        routeName: Routes.profile,
        reminders: reminders,
      );
      expect(find.text('21.00'), findsOneWidget);
      final before = reminders.syncs.length;

      await tester.tap(find.text('Jam pengingat'));
      await tester.pumpAndSettle();
      server.responses['/me'] = {..._me, 'reminderTime': '21:00'};
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(server.writes.single.method, 'PATCH');
      expect(server.writes.single.path, '/me');
      expect(server.writes.single.body, {'reminderTime': '21:00'});
      expect(reminders.syncs.length, greaterThan(before));
    });

    testWidgets('simpan gagal menampilkan pesan server', (tester) async {
      final server = _server()..failingPaths.add('/me');
      await pumpRoutedApp(tester, server, routeName: Routes.profile);

      await tester.tap(find.text('Jam pengingat'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('Terjadi kesalahan di server'), findsOneWidget);
    });

    testWidgets('izin mati ditampilkan', (tester) async {
      await pumpRoutedApp(
        tester,
        _server(),
        routeName: Routes.profile,
        reminders: FakeReminderService()..enabled = false,
      );
      expect(
        find.text('Izin notifikasi mati. Aktifkan di pengaturan HP.'),
        findsOneWidget,
      );
    });
  });

  group('Banner update', () {
    const version = {
      'latestVersion': '1.0.0',
      'downloadUrl': 'https://example.test/rilis',
    };

    setUp(
      () => PackageInfo.setMockInitialValues(
        appName: 'Direkapin',
        packageName: 'id.my.direkapin.app',
        version: '0.1.0',
        buildNumber: '1',
        buildSignature: '',
      ),
    );

    testWidgets('versi lebih baru: muncul, Update membuka link', (tester) async {
      final opened = <Object?>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('direkapin/links'),
        (call) async => opened.add(call.arguments),
      );
      await pumpRoutedApp(
        tester,
        _server(version: version),
        routeName: Routes.home,
      );

      expect(find.text('Versi baru 1.0.0 sudah ada.'), findsOneWidget);
      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();
      expect(opened, [
        {'url': 'https://example.test/rilis'},
      ]);
    });

    testWidgets('Nanti menutup banner', (tester) async {
      await pumpRoutedApp(
        tester,
        _server(version: version),
        routeName: Routes.home,
      );

      await tester.tap(find.text('Nanti'));
      await tester.pumpAndSettle();

      expect(find.text('Versi baru 1.0.0 sudah ada.'), findsNothing);
    });

    testWidgets('link bukan http: pesan, tidak membuka apa pun', (tester) async {
      await pumpRoutedApp(
        tester,
        _server(
          version: {'latestVersion': '1.0.0', 'downloadUrl': 'file:///x.apk'},
        ),
        routeName: Routes.home,
      );

      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      expect(find.text('Link update nggak bisa dibuka.'), findsOneWidget);
    });

    testWidgets('versi sama: tidak muncul', (tester) async {
      await pumpRoutedApp(
        tester,
        _server(
          version: {
            'latestVersion': '0.1.0',
            'downloadUrl': 'https://example.test/rilis',
          },
        ),
        routeName: Routes.home,
      );
      expect(find.text('Nanti'), findsNothing);
    });

    testWidgets('/version gagal: tidak muncul, Beranda tetap jalan', (
      tester,
    ) async {
      await pumpRoutedApp(
        tester,
        FakeServer({
          '/me': _me,
          '/dashboard': dashboardJson(),
          '/version': 500,
        }),
        routeName: Routes.home,
      );
      expect(find.text('Nanti'), findsNothing);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}
