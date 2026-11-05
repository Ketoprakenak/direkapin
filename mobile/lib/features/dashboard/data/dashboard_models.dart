import 'package:freezed_annotation/freezed_annotation.dart';

import '../../activity/data/activity_models.dart';
import '../../wallet/data/wallet_models.dart';

part 'dashboard_models.freezed.dart';
part 'dashboard_models.g.dart';

@freezed
abstract class MonthSummary with _$MonthSummary {
  const factory MonthSummary({
    required int income,
    required int expense,
    required int net,
  }) = _MonthSummary;

  factory MonthSummary.fromJson(Map<String, dynamic> json) =>
      _$MonthSummaryFromJson(json);
}

@freezed
abstract class TodaySummary with _$TodaySummary {
  const factory TodaySummary({
    required String date,
    required int expense,
    required List<Activity> activities,
    required bool hasEntry,
  }) = _TodaySummary;

  factory TodaySummary.fromJson(Map<String, dynamic> json) =>
      _$TodaySummaryFromJson(json);
}

@freezed
abstract class SeriesPoint with _$SeriesPoint {
  const factory SeriesPoint({
    required String label,
    required int income,
    required int expense,
  }) = _SeriesPoint;

  factory SeriesPoint.fromJson(Map<String, dynamic> json) =>
      _$SeriesPointFromJson(json);
}

@freezed
abstract class Streak with _$Streak {
  const factory Streak({required int current, required int longest}) = _Streak;

  factory Streak.fromJson(Map<String, dynamic> json) => _$StreakFromJson(json);
}

@freezed
abstract class Dashboard with _$Dashboard {
  const factory Dashboard({
    required int totalBalance,
    required List<Wallet> wallets,
    required MonthSummary month,
    required TodaySummary today,
    required List<SeriesPoint> last7Days,
    required Streak streak,
  }) = _Dashboard;

  factory Dashboard.fromJson(Map<String, dynamic> json) =>
      _$DashboardFromJson(json);
}
