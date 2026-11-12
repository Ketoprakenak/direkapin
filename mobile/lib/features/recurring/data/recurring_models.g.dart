// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecurringNext _$RecurringNextFromJson(Map<String, dynamic> json) =>
    _RecurringNext(
      month: json['month'] as String,
      dueDate: json['dueDate'] as String,
    );

Map<String, dynamic> _$RecurringNextToJson(_RecurringNext instance) =>
    <String, dynamic>{'month': instance.month, 'dueDate': instance.dueDate};

_Recurring _$RecurringFromJson(Map<String, dynamic> json) => _Recurring(
  id: json['id'] as String,
  type: $enumDecode(_$TxTypeEnumMap, json['type']),
  amount: (json['amount'] as num).toInt(),
  note: json['note'] as String?,
  dayOfMonth: (json['dayOfMonth'] as num).toInt(),
  startMonth: json['startMonth'] as String,
  endMonth: json['endMonth'] as String?,
  lastHandledMonth: json['lastHandledMonth'] as String?,
  wallet: WalletRef.fromJson(json['wallet'] as Map<String, dynamic>),
  category: CategoryRef.fromJson(json['category'] as Map<String, dynamic>),
  next: json['next'] == null
      ? null
      : RecurringNext.fromJson(json['next'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RecurringToJson(_Recurring instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$TxTypeEnumMap[instance.type]!,
      'amount': instance.amount,
      'note': instance.note,
      'dayOfMonth': instance.dayOfMonth,
      'startMonth': instance.startMonth,
      'endMonth': instance.endMonth,
      'lastHandledMonth': instance.lastHandledMonth,
      'wallet': instance.wallet,
      'category': instance.category,
      'next': instance.next,
    };

const _$TxTypeEnumMap = {TxType.income: 'INCOME', TxType.expense: 'EXPENSE'};

_RecurringDue _$RecurringDueFromJson(Map<String, dynamic> json) =>
    _RecurringDue(
      recurring: Recurring.fromJson(json['recurring'] as Map<String, dynamic>),
      month: json['month'] as String,
      dueDate: json['dueDate'] as String,
    );

Map<String, dynamic> _$RecurringDueToJson(_RecurringDue instance) =>
    <String, dynamic>{
      'recurring': instance.recurring,
      'month': instance.month,
      'dueDate': instance.dueDate,
    };
