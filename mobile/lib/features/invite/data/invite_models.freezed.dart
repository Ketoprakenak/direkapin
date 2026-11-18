// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invite_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Invite {

 String get code; DateTime get createdAt; DateTime get expiresAt; DateTime? get usedAt; String? get usedByName;
/// Create a copy of Invite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InviteCopyWith<Invite> get copyWith => _$InviteCopyWithImpl<Invite>(this as Invite, _$identity);

  /// Serializes this Invite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Invite;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Invite&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.usedAt, _this.usedAt) || other.usedAt == _this.usedAt)&&(identical(other.usedByName, _this.usedByName) || other.usedByName == _this.usedByName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Invite;
  return Object.hash(runtimeType,_this.code,_this.createdAt,_this.expiresAt,_this.usedAt,_this.usedByName);
}

@override
String toString() {
  final _this = this as Invite;
  return 'Invite(code: ${_this.code}, createdAt: ${_this.createdAt}, expiresAt: ${_this.expiresAt}, usedAt: ${_this.usedAt}, usedByName: ${_this.usedByName})';
}


}

/// @nodoc
abstract mixin class $InviteCopyWith<$Res>  {
  factory $InviteCopyWith(Invite value, $Res Function(Invite) _then) = _$InviteCopyWithImpl;
@useResult
$Res call({
 String code, DateTime createdAt, DateTime expiresAt, DateTime? usedAt, String? usedByName
});




}
/// @nodoc
class _$InviteCopyWithImpl<$Res>
    implements $InviteCopyWith<$Res> {
  _$InviteCopyWithImpl(this._self, this._then);

  final Invite _self;
  final $Res Function(Invite) _then;

/// Create a copy of Invite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? createdAt = null,Object? expiresAt = null,Object? usedAt = freezed,Object? usedByName = freezed,}) {
  return _then(Invite(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,usedAt: freezed == usedAt ? _self.usedAt : usedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,usedByName: freezed == usedByName ? _self.usedByName : usedByName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Invite].
extension InvitePatterns on Invite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Invite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Invite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Invite value)  $default,){
final _that = this;
switch (_that) {
case _Invite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Invite value)?  $default,){
final _that = this;
switch (_that) {
case _Invite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  DateTime createdAt,  DateTime expiresAt,  DateTime? usedAt,  String? usedByName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Invite() when $default != null:
return $default(_that.code,_that.createdAt,_that.expiresAt,_that.usedAt,_that.usedByName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  DateTime createdAt,  DateTime expiresAt,  DateTime? usedAt,  String? usedByName)  $default,) {final _that = this;
switch (_that) {
case _Invite():
return $default(_that.code,_that.createdAt,_that.expiresAt,_that.usedAt,_that.usedByName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  DateTime createdAt,  DateTime expiresAt,  DateTime? usedAt,  String? usedByName)?  $default,) {final _that = this;
switch (_that) {
case _Invite() when $default != null:
return $default(_that.code,_that.createdAt,_that.expiresAt,_that.usedAt,_that.usedByName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Invite extends Invite {
  const _Invite({required this.code, required this.createdAt, required this.expiresAt, this.usedAt, this.usedByName}): super._();
  factory _Invite.fromJson(Map<String, dynamic> json) => _$InviteFromJson(json);

@override final  String code;
@override final  DateTime createdAt;
@override final  DateTime expiresAt;
@override final  DateTime? usedAt;
@override final  String? usedByName;

/// Create a copy of Invite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InviteCopyWith<_Invite> get copyWith => __$InviteCopyWithImpl<_Invite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InviteToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Invite&&(identical(other.code, code) || other.code == code)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.usedAt, usedAt) || other.usedAt == usedAt)&&(identical(other.usedByName, usedByName) || other.usedByName == usedByName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,createdAt,expiresAt,usedAt,usedByName);
}

@override
String toString() {
    return 'Invite(code: $code, createdAt: $createdAt, expiresAt: $expiresAt, usedAt: $usedAt, usedByName: $usedByName)';
}


}

/// @nodoc
abstract mixin class _$InviteCopyWith<$Res> implements $InviteCopyWith<$Res> {
  factory _$InviteCopyWith(_Invite value, $Res Function(_Invite) _then) = __$InviteCopyWithImpl;
@override @useResult
$Res call({
 String code, DateTime createdAt, DateTime expiresAt, DateTime? usedAt, String? usedByName
});




}
/// @nodoc
class __$InviteCopyWithImpl<$Res>
    implements _$InviteCopyWith<$Res> {
  __$InviteCopyWithImpl(this._self, this._then);

  final _Invite _self;
  final $Res Function(_Invite) _then;

/// Create a copy of Invite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? createdAt = null,Object? expiresAt = null,Object? usedAt = freezed,Object? usedByName = freezed,}) {
  return _then(_Invite(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,usedAt: freezed == usedAt ? _self.usedAt : usedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,usedByName: freezed == usedByName ? _self.usedByName : usedByName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
