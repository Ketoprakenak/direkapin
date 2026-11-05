// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReportPeriod _$ReportPeriodFromJson(Map<String, dynamic> json) =>
    _ReportPeriod(start: json['start'] as String, end: json['end'] as String);

Map<String, dynamic> _$ReportPeriodToJson(_ReportPeriod instance) =>
    <String, dynamic>{'start': instance.start, 'end': instance.end};

_ReportTotals _$ReportTotalsFromJson(Map<String, dynamic> json) =>
    _ReportTotals(
      income: (json['income'] as num).toInt(),
      expense: (json['expense'] as num).toInt(),
      net: (json['net'] as num).toInt(),
      transactionCount: (json['transactionCount'] as num).toInt(),
    );

Map<String, dynamic> _$ReportTotalsToJson(_ReportTotals instance) =>
    <String, dynamic>{
      'income': instance.income,
      'expense': instance.expense,
      'net': instance.net,
      'transactionCount': instance.transactionCount,
    };

_CategoryShare _$CategoryShareFromJson(Map<String, dynamic> json) =>
    _CategoryShare(
      category: CategoryRef.fromJson(json['category'] as Map<String, dynamic>),
      amount: (json['amount'] as num).toInt(),
      share: (json['share'] as num).toDouble(),
    );

Map<String, dynamic> _$CategoryShareToJson(_CategoryShare instance) =>
    <String, dynamic>{
      'category': instance.category,
      'amount': instance.amount,
      'share': instance.share,
    };

_ReportComparison _$ReportComparisonFromJson(Map<String, dynamic> json) =>
    _ReportComparison(
      previousExpense: (json['previousExpense'] as num).toInt(),
      changePct: (json['changePct'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ReportComparisonToJson(_ReportComparison instance) =>
    <String, dynamic>{
      'previousExpense': instance.previousExpense,
      'changePct': instance.changePct,
    };

_Report _$ReportFromJson(Map<String, dynamic> json) => _Report(
  period: ReportPeriod.fromJson(json['period'] as Map<String, dynamic>),
  totals: ReportTotals.fromJson(json['totals'] as Map<String, dynamic>),
  series: (json['series'] as List<dynamic>)
      .map((e) => SeriesPoint.fromJson(e as Map<String, dynamic>))
      .toList(),
  byCategory: (json['byCategory'] as List<dynamic>)
      .map((e) => CategoryShare.fromJson(e as Map<String, dynamic>))
      .toList(),
  comparison: json['comparison'] == null
      ? null
      : ReportComparison.fromJson(json['comparison'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ReportToJson(_Report instance) => <String, dynamic>{
  'period': instance.period,
  'totals': instance.totals,
  'series': instance.series,
  'byCategory': instance.byCategory,
  'comparison': instance.comparison,
};
