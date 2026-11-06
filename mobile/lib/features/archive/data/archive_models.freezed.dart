// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'archive_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Archive {

 String get id; String get month; int get sizeBytes; int get photoCount; ArchiveStatus get status; DateTime get createdAt; DateTime get expiresAt; DateTime? get downloadedAt;
/// Create a copy of Archive
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArchiveCopyWith<Archive> get copyWith => _$ArchiveCopyWithImpl<Archive>(this as Archive, _$identity);

  /// Serializes this Archive to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Archive;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Archive&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.month, _this.month) || other.month == _this.month)&&(identical(other.sizeBytes, _this.sizeBytes) || other.sizeBytes == _this.sizeBytes)&&(identical(other.photoCount, _this.photoCount) || other.photoCount == _this.photoCount)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.downloadedAt, _this.downloadedAt) || other.downloadedAt == _this.downloadedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Archive;
  return Object.hash(runtimeType,_this.id,_this.month,_this.sizeBytes,_this.photoCount,_this.status,_this.createdAt,_this.expiresAt,_this.downloadedAt);
}

@override
String toString() {
  final _this = this as Archive;
  return 'Archive(id: ${_this.id}, month: ${_this.month}, sizeBytes: ${_this.sizeBytes}, photoCount: ${_this.photoCount}, status: ${_this.status}, createdAt: ${_this.createdAt}, expiresAt: ${_this.expiresAt}, downloadedAt: ${_this.downloadedAt})';
}


}

/// @nodoc
abstract mixin class $ArchiveCopyWith<$Res>  {
  factory $ArchiveCopyWith(Archive value, $Res Function(Archive) _then) = _$ArchiveCopyWithImpl;
@useResult
$Res call({
 String id, String month, int sizeBytes, int photoCount, ArchiveStatus status, DateTime createdAt, DateTime expiresAt, DateTime? downloadedAt
});




}
/// @nodoc
class _$ArchiveCopyWithImpl<$Res>
    implements $ArchiveCopyWith<$Res> {
  _$ArchiveCopyWithImpl(this._self, this._then);

  final Archive _self;
  final $Res Function(Archive) _then;

/// Create a copy of Archive
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? month = null,Object? sizeBytes = null,Object? photoCount = null,Object? status = null,Object? createdAt = null,Object? expiresAt = null,Object? downloadedAt = freezed,}) {
  return _then(Archive(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,photoCount: null == photoCount ? _self.photoCount : photoCount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ArchiveStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,downloadedAt: freezed == downloadedAt ? _self.downloadedAt : downloadedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Archive].
extension ArchivePatterns on Archive {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Archive value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Archive() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Archive value)  $default,){
final _that = this;
switch (_that) {
case _Archive():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Archive value)?  $default,){
final _that = this;
switch (_that) {
case _Archive() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String month,  int sizeBytes,  int photoCount,  ArchiveStatus status,  DateTime createdAt,  DateTime expiresAt,  DateTime? downloadedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Archive() when $default != null:
return $default(_that.id,_that.month,_that.sizeBytes,_that.photoCount,_that.status,_that.createdAt,_that.expiresAt,_that.downloadedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String month,  int sizeBytes,  int photoCount,  ArchiveStatus status,  DateTime createdAt,  DateTime expiresAt,  DateTime? downloadedAt)  $default,) {final _that = this;
switch (_that) {
case _Archive():
return $default(_that.id,_that.month,_that.sizeBytes,_that.photoCount,_that.status,_that.createdAt,_that.expiresAt,_that.downloadedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String month,  int sizeBytes,  int photoCount,  ArchiveStatus status,  DateTime createdAt,  DateTime expiresAt,  DateTime? downloadedAt)?  $default,) {final _that = this;
switch (_that) {
case _Archive() when $default != null:
return $default(_that.id,_that.month,_that.sizeBytes,_that.photoCount,_that.status,_that.createdAt,_that.expiresAt,_that.downloadedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Archive implements Archive {
  const _Archive({required this.id, required this.month, required this.sizeBytes, required this.photoCount, required this.status, required this.createdAt, required this.expiresAt, this.downloadedAt});
  factory _Archive.fromJson(Map<String, dynamic> json) => _$ArchiveFromJson(json);

@override final  String id;
@override final  String month;
@override final  int sizeBytes;
@override final  int photoCount;
@override final  ArchiveStatus status;
@override final  DateTime createdAt;
@override final  DateTime expiresAt;
@override final  DateTime? downloadedAt;

/// Create a copy of Archive
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArchiveCopyWith<_Archive> get copyWith => __$ArchiveCopyWithImpl<_Archive>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ArchiveToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Archive&&(identical(other.id, id) || other.id == id)&&(identical(other.month, month) || other.month == month)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.photoCount, photoCount) || other.photoCount == photoCount)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.downloadedAt, downloadedAt) || other.downloadedAt == downloadedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,month,sizeBytes,photoCount,status,createdAt,expiresAt,downloadedAt);
}

@override
String toString() {
    return 'Archive(id: $id, month: $month, sizeBytes: $sizeBytes, photoCount: $photoCount, status: $status, createdAt: $createdAt, expiresAt: $expiresAt, downloadedAt: $downloadedAt)';
}


}

/// @nodoc
abstract mixin class _$ArchiveCopyWith<$Res> implements $ArchiveCopyWith<$Res> {
  factory _$ArchiveCopyWith(_Archive value, $Res Function(_Archive) _then) = __$ArchiveCopyWithImpl;
@override @useResult
$Res call({
 String id, String month, int sizeBytes, int photoCount, ArchiveStatus status, DateTime createdAt, DateTime expiresAt, DateTime? downloadedAt
});




}
/// @nodoc
class __$ArchiveCopyWithImpl<$Res>
    implements _$ArchiveCopyWith<$Res> {
  __$ArchiveCopyWithImpl(this._self, this._then);

  final _Archive _self;
  final $Res Function(_Archive) _then;

/// Create a copy of Archive
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? month = null,Object? sizeBytes = null,Object? photoCount = null,Object? status = null,Object? createdAt = null,Object? expiresAt = null,Object? downloadedAt = freezed,}) {
  return _then(_Archive(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as String,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,photoCount: null == photoCount ? _self.photoCount : photoCount // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ArchiveStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,downloadedAt: freezed == downloadedAt ? _self.downloadedAt : downloadedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
