// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Category {

 String get id; String get name; TxType get type; String get icon; String get color; bool get isDefault; bool get isHidden; int get sortOrder;
/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryCopyWith<Category> get copyWith => _$CategoryCopyWithImpl<Category>(this as Category, _$identity);

  /// Serializes this Category to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Category;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Category&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.isDefault, _this.isDefault) || other.isDefault == _this.isDefault)&&(identical(other.isHidden, _this.isHidden) || other.isHidden == _this.isHidden)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Category;
  return Object.hash(runtimeType,_this.id,_this.name,_this.type,_this.icon,_this.color,_this.isDefault,_this.isHidden,_this.sortOrder);
}

@override
String toString() {
  final _this = this as Category;
  return 'Category(id: ${_this.id}, name: ${_this.name}, type: ${_this.type}, icon: ${_this.icon}, color: ${_this.color}, isDefault: ${_this.isDefault}, isHidden: ${_this.isHidden}, sortOrder: ${_this.sortOrder})';
}


}

/// @nodoc
abstract mixin class $CategoryCopyWith<$Res>  {
  factory $CategoryCopyWith(Category value, $Res Function(Category) _then) = _$CategoryCopyWithImpl;
@useResult
$Res call({
 String id, String name, TxType type, String icon, String color, bool isDefault, bool isHidden, int sortOrder
});




}
/// @nodoc
class _$CategoryCopyWithImpl<$Res>
    implements $CategoryCopyWith<$Res> {
  _$CategoryCopyWithImpl(this._self, this._then);

  final Category _self;
  final $Res Function(Category) _then;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? icon = null,Object? color = null,Object? isDefault = null,Object? isHidden = null,Object? sortOrder = null,}) {
  return _then(Category(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TxType,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Category].
extension CategoryPatterns on Category {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Category value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Category() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Category value)  $default,){
final _that = this;
switch (_that) {
case _Category():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Category value)?  $default,){
final _that = this;
switch (_that) {
case _Category() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  TxType type,  String icon,  String color,  bool isDefault,  bool isHidden,  int sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.icon,_that.color,_that.isDefault,_that.isHidden,_that.sortOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  TxType type,  String icon,  String color,  bool isDefault,  bool isHidden,  int sortOrder)  $default,) {final _that = this;
switch (_that) {
case _Category():
return $default(_that.id,_that.name,_that.type,_that.icon,_that.color,_that.isDefault,_that.isHidden,_that.sortOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  TxType type,  String icon,  String color,  bool isDefault,  bool isHidden,  int sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _Category() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.icon,_that.color,_that.isDefault,_that.isHidden,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Category implements Category {
  const _Category({required this.id, required this.name, required this.type, required this.icon, required this.color, required this.isDefault, required this.isHidden, required this.sortOrder});
  factory _Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

@override final  String id;
@override final  String name;
@override final  TxType type;
@override final  String icon;
@override final  String color;
@override final  bool isDefault;
@override final  bool isHidden;
@override final  int sortOrder;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryCopyWith<_Category> get copyWith => __$CategoryCopyWithImpl<_Category>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Category&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.isHidden, isHidden) || other.isHidden == isHidden)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,type,icon,color,isDefault,isHidden,sortOrder);
}

@override
String toString() {
    return 'Category(id: $id, name: $name, type: $type, icon: $icon, color: $color, isDefault: $isDefault, isHidden: $isHidden, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$CategoryCopyWith<$Res> implements $CategoryCopyWith<$Res> {
  factory _$CategoryCopyWith(_Category value, $Res Function(_Category) _then) = __$CategoryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, TxType type, String icon, String color, bool isDefault, bool isHidden, int sortOrder
});




}
/// @nodoc
class __$CategoryCopyWithImpl<$Res>
    implements _$CategoryCopyWith<$Res> {
  __$CategoryCopyWithImpl(this._self, this._then);

  final _Category _self;
  final $Res Function(_Category) _then;

/// Create a copy of Category
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? icon = null,Object? color = null,Object? isDefault = null,Object? isHidden = null,Object? sortOrder = null,}) {
  return _then(_Category(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TxType,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,isHidden: null == isHidden ? _self.isHidden : isHidden // ignore: cast_nullable_to_non_nullable
as bool,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$CategoryRef {

 String get id; String get name; String get icon; String get color;
/// Create a copy of CategoryRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoryRefCopyWith<CategoryRef> get copyWith => _$CategoryRefCopyWithImpl<CategoryRef>(this as CategoryRef, _$identity);

  /// Serializes this CategoryRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CategoryRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CategoryRef&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.color, _this.color) || other.color == _this.color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CategoryRef;
  return Object.hash(runtimeType,_this.id,_this.name,_this.icon,_this.color);
}

@override
String toString() {
  final _this = this as CategoryRef;
  return 'CategoryRef(id: ${_this.id}, name: ${_this.name}, icon: ${_this.icon}, color: ${_this.color})';
}


}

/// @nodoc
abstract mixin class $CategoryRefCopyWith<$Res>  {
  factory $CategoryRefCopyWith(CategoryRef value, $Res Function(CategoryRef) _then) = _$CategoryRefCopyWithImpl;
@useResult
$Res call({
 String id, String name, String icon, String color
});




}
/// @nodoc
class _$CategoryRefCopyWithImpl<$Res>
    implements $CategoryRefCopyWith<$Res> {
  _$CategoryRefCopyWithImpl(this._self, this._then);

  final CategoryRef _self;
  final $Res Function(CategoryRef) _then;

/// Create a copy of CategoryRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? icon = null,Object? color = null,}) {
  return _then(CategoryRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CategoryRef].
extension CategoryRefPatterns on CategoryRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CategoryRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CategoryRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CategoryRef value)  $default,){
final _that = this;
switch (_that) {
case _CategoryRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CategoryRef value)?  $default,){
final _that = this;
switch (_that) {
case _CategoryRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String icon,  String color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CategoryRef() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String icon,  String color)  $default,) {final _that = this;
switch (_that) {
case _CategoryRef():
return $default(_that.id,_that.name,_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String icon,  String color)?  $default,) {final _that = this;
switch (_that) {
case _CategoryRef() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.color);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CategoryRef implements CategoryRef {
  const _CategoryRef({required this.id, required this.name, required this.icon, required this.color});
  factory _CategoryRef.fromJson(Map<String, dynamic> json) => _$CategoryRefFromJson(json);

@override final  String id;
@override final  String name;
@override final  String icon;
@override final  String color;

/// Create a copy of CategoryRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoryRefCopyWith<_CategoryRef> get copyWith => __$CategoryRefCopyWithImpl<_CategoryRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoryRefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoryRef&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,icon,color);
}

@override
String toString() {
    return 'CategoryRef(id: $id, name: $name, icon: $icon, color: $color)';
}


}

/// @nodoc
abstract mixin class _$CategoryRefCopyWith<$Res> implements $CategoryRefCopyWith<$Res> {
  factory _$CategoryRefCopyWith(_CategoryRef value, $Res Function(_CategoryRef) _then) = __$CategoryRefCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String icon, String color
});




}
/// @nodoc
class __$CategoryRefCopyWithImpl<$Res>
    implements _$CategoryRefCopyWith<$Res> {
  __$CategoryRefCopyWithImpl(this._self, this._then);

  final _CategoryRef _self;
  final $Res Function(_CategoryRef) _then;

/// Create a copy of CategoryRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? icon = null,Object? color = null,}) {
  return _then(_CategoryRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
