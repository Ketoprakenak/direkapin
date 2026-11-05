// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CalendarDay _$CalendarDayFromJson(Map<String, dynamic> json) => _CalendarDay(
  date: json['date'] as String,
  income: (json['income'] as num).toInt(),
  expense: (json['expense'] as num).toInt(),
  activityCount: (json['activityCount'] as num).toInt(),
  hasImportant: json['hasImportant'] as bool,
);

Map<String, dynamic> _$CalendarDayToJson(_CalendarDay instance) =>
    <String, dynamic>{
      'date': instance.date,
      'income': instance.income,
      'expense': instance.expense,
      'activityCount': instance.activityCount,
      'hasImportant': instance.hasImportant,
    };

_DayDetail _$DayDetailFromJson(Map<String, dynamic> json) => _DayDetail(
  date: json['date'] as String,
  income: (json['income'] as num).toInt(),
  expense: (json['expense'] as num).toInt(),
  transactions: (json['transactions'] as List<dynamic>)
      .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
      .toList(),
  transfers: (json['transfers'] as List<dynamic>)
      .map((e) => Transfer.fromJson(e as Map<String, dynamic>))
      .toList(),
  activities: (json['activities'] as List<dynamic>)
      .map((e) => Activity.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DayDetailToJson(_DayDetail instance) =>
    <String, dynamic>{
      'date': instance.date,
      'income': instance.income,
      'expense': instance.expense,
      'transactions': instance.transactions,
      'transfers': instance.transfers,
      'activities': instance.activities,
    };
