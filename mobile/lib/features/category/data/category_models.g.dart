// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Category _$CategoryFromJson(Map<String, dynamic> json) => _Category(
  id: json['id'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$TxTypeEnumMap, json['type']),
  icon: json['icon'] as String,
  color: json['color'] as String,
  isDefault: json['isDefault'] as bool,
  isHidden: json['isHidden'] as bool,
  sortOrder: (json['sortOrder'] as num).toInt(),
);

Map<String, dynamic> _$CategoryToJson(_Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': _$TxTypeEnumMap[instance.type]!,
  'icon': instance.icon,
  'color': instance.color,
  'isDefault': instance.isDefault,
  'isHidden': instance.isHidden,
  'sortOrder': instance.sortOrder,
};

const _$TxTypeEnumMap = {TxType.income: 'INCOME', TxType.expense: 'EXPENSE'};

_CategoryRef _$CategoryRefFromJson(Map<String, dynamic> json) => _CategoryRef(
  id: json['id'] as String,
  name: json['name'] as String,
  icon: json['icon'] as String,
  color: json['color'] as String,
);

Map<String, dynamic> _$CategoryRefToJson(_CategoryRef instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'color': instance.color,
    };
