// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Budget _$BudgetFromJson(Map<String, dynamic> json) => _Budget(
  id: json['id'] as String,
  name: json['name'] as String,
  limitAmount: (json['limitAmount'] as num).toInt(),
  startMonth: json['startMonth'] as String,
  endMonth: json['endMonth'] as String?,
  categories: (json['categories'] as List<dynamic>)
      .map((e) => CategoryRef.fromJson(e as Map<String, dynamic>))
      .toList(),
  spent: (json['spent'] as num).toInt(),
);

Map<String, dynamic> _$BudgetToJson(_Budget instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'limitAmount': instance.limitAmount,
  'startMonth': instance.startMonth,
  'endMonth': instance.endMonth,
  'categories': instance.categories,
  'spent': instance.spent,
};
