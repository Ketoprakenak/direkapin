// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Activity _$ActivityFromJson(Map<String, dynamic> json) => _Activity(
  id: json['id'] as String,
  title: json['title'] as String,
  date: json['date'] as String,
  time: json['time'] as String?,
  location: json['location'] as String?,
  description: json['description'] as String?,
  isImportant: json['isImportant'] as bool,
);

Map<String, dynamic> _$ActivityToJson(_Activity instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'date': instance.date,
  'time': instance.time,
  'location': instance.location,
  'description': instance.description,
  'isImportant': instance.isImportant,
};
