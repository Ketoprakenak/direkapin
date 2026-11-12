import 'package:freezed_annotation/freezed_annotation.dart';

import '../../category/data/category_models.dart';
import '../../dashboard/data/dashboard_models.dart';

part 'report_models.freezed.dart';
part 'report_models.g.dart';

enum ReportType { weekly, monthly, range }

@freezed
abstract class ReportPeriod with _$ReportPeriod {
  const factory ReportPeriod({required String start, required String end}) =
      _ReportPeriod;

  factory ReportPeriod.fromJson(Map<String, dynamic> json) =>
      _$ReportPeriodFromJson(json);
}

@freezed
abstract class ReportTotals with _$ReportTotals {
  const factory ReportTotals({
    required int income,
    required int expense,
    required int net,
    required int transactionCount,
  }) = _ReportTotals;

  factory ReportTotals.fromJson(Map<String, dynamic> json) =>
      _$ReportTotalsFromJson(json);
}

@freezed
abstract class CategoryShare with _$CategoryShare {
  const factory CategoryShare({
    required CategoryRef category,
    required int amount,
    required double share,
  }) = _CategoryShare;

  factory CategoryShare.fromJson(Map<String, dynamic> json) =>
      _$CategoryShareFromJson(json);
}

@freezed
abstract class ReportComparison with _$ReportComparison {
  const factory ReportComparison({
    required int previousExpense,
    double? changePct,
  }) = _ReportComparison;

  factory ReportComparison.fromJson(Map<String, dynamic> json) =>
      _$ReportComparisonFromJson(json);
}

@freezed
abstract class Report with _$Report {
  const factory Report({
    required ReportPeriod period,
    required ReportTotals totals,
    required List<SeriesPoint> series,
    required List<CategoryShare> byCategory,
    ReportComparison? comparison,
  }) = _Report;

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
}
