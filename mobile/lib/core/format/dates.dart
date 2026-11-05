import 'package:intl/intl.dart';

/// `Rabu, 4 November 2026`
String formatLongDate(DateTime date) =>
    DateFormat('EEEE, d MMMM y', 'id_ID').format(date);

/// `4 Nov`
String formatShortDate(DateTime date) =>
    DateFormat('d MMM', 'id_ID').format(date);

/// `November 2026`
String formatMonth(DateTime date) =>
    DateFormat('MMMM y', 'id_ID').format(date);

/// `Rab`
String formatWeekday(DateTime date) => DateFormat('E', 'id_ID').format(date);

/// `2026-11-04`, tanggal seperti yang tertera di [date], tanpa konversi zona.
String dateKey(DateTime date) =>
    '${monthKey(date)}-${date.day.toString().padLeft(2, '0')}';

/// `2026-11`
String monthKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';

/// `21.00`
String formatTime(DateTime date) => DateFormat('HH.mm').format(date);

/// `21.00` dari jam kegiatan `21:00`; tanpa jam = `Seharian`.
String formatActivityTime(String? time) =>
    time?.replaceFirst(':', '.') ?? 'Seharian';
