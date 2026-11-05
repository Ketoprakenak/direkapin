// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MonthSummary _$MonthSummaryFromJson(Map<String, dynamic> json) =>
    _MonthSummary(
      income: (json['income'] as num).toInt(),
      expense: (json['expense'] as num).toInt(),
      net: (json['net'] as num).toInt(),
    );

Map<String, dynamic> _$MonthSummaryToJson(_MonthSummary instance) =>
    <String, dynamic>{
      'income': instance.income,
      'expense': instance.expense,
      'net': instance.net,
    };

_TodaySummary _$TodaySummaryFromJson(Map<String, dynamic> json) =>
    _TodaySummary(
      date: json['date'] as String,
      expense: (json['expense'] as num).toInt(),
      activities: (json['activities'] as List<dynamic>)
          .map((e) => Activity.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasEntry: json['hasEntry'] as bool,
    );

Map<String, dynamic> _$TodaySummaryToJson(_TodaySummary instance) =>
    <String, dynamic>{
      'date': instance.date,
      'expense': instance.expense,
      'activities': instance.activities,
      'hasEntry': instance.hasEntry,
    };

_SeriesPoint _$SeriesPointFromJson(Map<String, dynamic> json) => _SeriesPoint(
  label: json['label'] as String,
  income: (json['income'] as num).toInt(),
  expense: (json['expense'] as num).toInt(),
);

Map<String, dynamic> _$SeriesPointToJson(_SeriesPoint instance) =>
    <String, dynamic>{
      'label': instance.label,
      'income': instance.income,
      'expense': instance.expense,
    };

_Streak _$StreakFromJson(Map<String, dynamic> json) => _Streak(
  current: (json['current'] as num).toInt(),
  longest: (json['longest'] as num).toInt(),
);

Map<String, dynamic> _$StreakToJson(_Streak instance) => <String, dynamic>{
  'current': instance.current,
  'longest': instance.longest,
};

_Dashboard _$DashboardFromJson(Map<String, dynamic> json) => _Dashboard(
  totalBalance: (json['totalBalance'] as num).toInt(),
  wallets: (json['wallets'] as List<dynamic>)
      .map((e) => Wallet.fromJson(e as Map<String, dynamic>))
      .toList(),
  month: MonthSummary.fromJson(json['month'] as Map<String, dynamic>),
  today: TodaySummary.fromJson(json['today'] as Map<String, dynamic>),
  last7Days: (json['last7Days'] as List<dynamic>)
      .map((e) => SeriesPoint.fromJson(e as Map<String, dynamic>))
      .toList(),
  streak: Streak.fromJson(json['streak'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DashboardToJson(_Dashboard instance) =>
    <String, dynamic>{
      'totalBalance': instance.totalBalance,
      'wallets': instance.wallets,
      'month': instance.month,
      'today': instance.today,
      'last7Days': instance.last7Days,
      'streak': instance.streak,
    };
