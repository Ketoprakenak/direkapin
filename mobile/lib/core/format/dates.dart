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

/// `21.00`
String formatTime(DateTime date) => DateFormat('HH.mm').format(date);
