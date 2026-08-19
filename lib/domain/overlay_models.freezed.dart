// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'overlay_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OverlayTextStyle {

 double get fontSize; String get color; OverlayTextAlignment get alignment;
/// Create a copy of OverlayTextStyle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OverlayTextStyleCopyWith<OverlayTextStyle> get copyWith => _$OverlayTextStyleCopyWithImpl<OverlayTextStyle>(this as OverlayTextStyle, _$identity);

  /// Serializes this OverlayTextStyle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OverlayTextStyle&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.color, color) || other.color == color)&&(identical(other.alignment, alignment) || other.alignment == alignment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fontSize,color,alignment);

@override
String toString() {
  return 'OverlayTextStyle(fontSize: $fontSize, color: $color, alignment: $alignment)';
}


}

/// @nodoc
abstract mixin class $OverlayTextStyleCopyWith<$Res>  {
  factory $OverlayTextStyleCopyWith(OverlayTextStyle value, $Res Function(OverlayTextStyle) _then) = _$OverlayTextStyleCopyWithImpl;
@useResult
$Res call({
 double fontSize, String color, OverlayTextAlignment alignment
});




}
/// @nodoc
class _$OverlayTextStyleCopyWithImpl<$Res>
    implements $OverlayTextStyleCopyWith<$Res> {
  _$OverlayTextStyleCopyWithImpl(this._self, this._then);

  final OverlayTextStyle _self;
  final $Res Function(OverlayTextStyle) _then;

/// Create a copy of OverlayTextStyle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fontSize = null,Object? color = null,Object? alignment = null,}) {
  return _then(OverlayTextStyle(
fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,alignment: null == alignment ? _self.alignment : alignment // ignore: cast_nullable_to_non_nullable
as OverlayTextAlignment,
  ));
}

}


/// Adds pattern-matching-related methods to [OverlayTextStyle].
extension OverlayTextStylePatterns on OverlayTextStyle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OverlayTextStyle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OverlayTextStyle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OverlayTextStyle value)  $default,){
final _that = this;
switch (_that) {
case _OverlayTextStyle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OverlayTextStyle value)?  $default,){
final _that = this;
switch (_that) {
case _OverlayTextStyle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double fontSize,  String color,  OverlayTextAlignment alignment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OverlayTextStyle() when $default != null:
return $default(_that.fontSize,_that.color,_that.alignment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double fontSize,  String color,  OverlayTextAlignment alignment)  $default,) {final _that = this;
switch (_that) {
case _OverlayTextStyle():
return $default(_that.fontSize,_that.color,_that.alignment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double fontSize,  String color,  OverlayTextAlignment alignment)?  $default,) {final _that = this;
switch (_that) {
case _OverlayTextStyle() when $default != null:
return $default(_that.fontSize,_that.color,_that.alignment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OverlayTextStyle implements OverlayTextStyle {
  const _OverlayTextStyle({this.fontSize = 24, this.color = '#FFFFFFFF', this.alignment = OverlayTextAlignment.left});
  factory _OverlayTextStyle.fromJson(Map<String, dynamic> json) => _$OverlayTextStyleFromJson(json);

@override@JsonKey() final  double fontSize;
@override@JsonKey() final  String color;
@override@JsonKey() final  OverlayTextAlignment alignment;

/// Create a copy of OverlayTextStyle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OverlayTextStyleCopyWith<_OverlayTextStyle> get copyWith => __$OverlayTextStyleCopyWithImpl<_OverlayTextStyle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OverlayTextStyleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OverlayTextStyle&&(identical(other.fontSize, fontSize) || other.fontSize == fontSize)&&(identical(other.color, color) || other.color == color)&&(identical(other.alignment, alignment) || other.alignment == alignment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fontSize,color,alignment);

@override
String toString() {
  return 'OverlayTextStyle(fontSize: $fontSize, color: $color, alignment: $alignment)';
}


}

/// @nodoc
abstract mixin class _$OverlayTextStyleCopyWith<$Res> implements $OverlayTextStyleCopyWith<$Res> {
  factory _$OverlayTextStyleCopyWith(_OverlayTextStyle value, $Res Function(_OverlayTextStyle) _then) = __$OverlayTextStyleCopyWithImpl;
@override @useResult
$Res call({
 double fontSize, String color, OverlayTextAlignment alignment
});




}
/// @nodoc
class __$OverlayTextStyleCopyWithImpl<$Res>
    implements _$OverlayTextStyleCopyWith<$Res> {
  __$OverlayTextStyleCopyWithImpl(this._self, this._then);

  final _OverlayTextStyle _self;
  final $Res Function(_OverlayTextStyle) _then;

/// Create a copy of OverlayTextStyle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fontSize = null,Object? color = null,Object? alignment = null,}) {
  return _then(_OverlayTextStyle(
fontSize: null == fontSize ? _self.fontSize : fontSize // ignore: cast_nullable_to_non_nullable
as double,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,alignment: null == alignment ? _self.alignment : alignment // ignore: cast_nullable_to_non_nullable
as OverlayTextAlignment,
  ));
}


}

// dart format on
