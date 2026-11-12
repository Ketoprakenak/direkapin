import 'package:freezed_annotation/freezed_annotation.dart';

import '../../activity/data/activity_models.dart';
import '../../transaction/data/transaction_models.dart';
import '../../wallet/data/wallet_models.dart';

part 'calendar_models.freezed.dart';
part 'calendar_models.g.dart';

@freezed
abstract class CalendarDay with _$CalendarDay {
  const factory CalendarDay({
    required String date,
    required int income,
    required int expense,
    required int activityCount,
    required bool hasImportant,

    /// Emoji mood hari itu (ACT-05, D-61).
    String? mood,
  }) = _CalendarDay;

  factory CalendarDay.fromJson(Map<String, dynamic> json) =>
      _$CalendarDayFromJson(json);
}

/// Mood dan catatan harian (ACT-05).
@freezed
abstract class DailyNote with _$DailyNote {
  const factory DailyNote({required String date, String? mood, String? note}) =
      _DailyNote;

  factory DailyNote.fromJson(Map<String, dynamic> json) =>
      _$DailyNoteFromJson(json);
}

@freezed
abstract class DayDetail with _$DayDetail {
  const factory DayDetail({
    required String date,
    required int income,
    required int expense,
    required List<Transaction> transactions,
    required List<Transfer> transfers,
    required List<Activity> activities,
    DailyNote? note,
  }) = _DayDetail;

  factory DayDetail.fromJson(Map<String, dynamic> json) =>
      _$DayDetailFromJson(json);
}
