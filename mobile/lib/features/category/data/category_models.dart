import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_models.freezed.dart';
part 'category_models.g.dart';

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum TxType {
  income,
  expense;

  String get apiValue => name.toUpperCase();
}

@freezed
abstract class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    required TxType type,
    required String icon,
    required String color,
    required bool isDefault,
    required bool isHidden,
    required int sortOrder,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}

@freezed
abstract class CategoryRef with _$CategoryRef {
  const factory CategoryRef({
    required String id,
    required String name,
    required String icon,
    required String color,
  }) = _CategoryRef;

  factory CategoryRef.fromJson(Map<String, dynamic> json) =>
      _$CategoryRefFromJson(json);
}
