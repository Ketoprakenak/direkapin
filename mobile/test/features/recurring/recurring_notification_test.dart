import 'package:direkapin/core/notifications/reminder_service.dart';
import 'package:direkapin/core/router/router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../helpers/fake_server.dart';
import '../../helpers/recurring_fixtures.dart';

const _me = {
  'id': 'u1',
  'name': 'Desta',
  'email': 'd@x.com',
  'timezone': 'Asia/Jakarta',
  'reminderTime': '21:00',
  'hasAvatar': false,
  'createdAt': '2026-11-01T00:00:00.000Z',
};

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
    return initializeDateFormatting('id_ID');
  });

  test('recurringReminderDates: 09.00 di hari jatuh tempo, yang lewat dibuang', () {
    final jakarta = tz.getLocation('Asia/Jakarta');
    final now = tz.TZDateTime(jakarta, 2026, 11, 5, 10);
    final items = recurringReminderDates([
      (dueDate: '2026-12-01', label: 'Kos', amount: 1500000),
      (dueDate: '2026-11-05', label: 'Listrik', amount: 200000), // 09.00 lewat
      (dueDate: '2026-11-20', label: 'Internet', amount: 300000),
    ], now);
    expect(items.map((i) => i.date), [
      tz.TZDateTime(jakarta, 2026, 11, 20, 9),
      tz.TZDateTime(jakarta, 2026, 12, 1, 9),
    ]);
    expect(
      items.first.body,
      'Internet Rp300.000 jatuh tempo hari ini. Catat atau lewati di Beranda.',
    );

    final many = recurringReminderDates([
      for (var day = 1; day <= 28; day++)
        (
          dueDate: '2026-12-${day.toString().padLeft(2, '0')}',
          label: 'x',
          amount: 1,
        ),
    ], now);
    expect(many, hasLength(20));

    // Mode uji: yang sudah lewat tetap dijadwalkan beberapa menit lagi.
    final test = recurringReminderDates(
      [(dueDate: '2026-11-01', label: 'Kos', amount: 1)],
      now,
      testInMinutes: 2,
    );
    expect(test.single.date, now.add(const Duration(minutes: 2)));
  });

  testWidgets('dibuka: aturan dengan next dijadwalkan, label dari catatan', (
    tester,
  ) async {
    final reminders = FakeReminderService();
    await pumpRoutedApp(
      tester,
      FakeServer({
        '/me': _me,
        '/dashboard': dashboardJson(),
        '/recurring': {
          'items': [
            {...recurringJson(id: 'r1'), 'note': ' Kos '},
            {
              ...recurringJson(id: 'r2', amount: 99000),
              'next': {'month': '2026-12', 'dueDate': '2026-12-10'},
            },
            {...recurringJson(id: 'r3'), 'next': null},
          ],
        },
      }),
      routeName: Routes.home,
      reminders: reminders,
    );

    expect(reminders.recurringSyncs.last, [
      (dueDate: '2026-11-05', label: 'Kos', amount: 150000),
      (dueDate: '2026-12-10', label: 'Listrik', amount: 99000),
    ]);
  });
}
