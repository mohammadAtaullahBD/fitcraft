// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'body_measurements.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BodyMeasurements {

 double get shoulderWidth; double get hipWidth; double get torsoLength; double get estimatedHeight;
/// Create a copy of BodyMeasurements
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BodyMeasurementsCopyWith<BodyMeasurements> get copyWith => _$BodyMeasurementsCopyWithImpl<BodyMeasurements>(this as BodyMeasurements, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BodyMeasurements&&(identical(other.shoulderWidth, shoulderWidth) || other.shoulderWidth == shoulderWidth)&&(identical(other.hipWidth, hipWidth) || other.hipWidth == hipWidth)&&(identical(other.torsoLength, torsoLength) || other.torsoLength == torsoLength)&&(identical(other.estimatedHeight, estimatedHeight) || other.estimatedHeight == estimatedHeight));
}


@override
int get hashCode => Object.hash(runtimeType,shoulderWidth,hipWidth,torsoLength,estimatedHeight);

@override
String toString() {
  return 'BodyMeasurements(shoulderWidth: $shoulderWidth, hipWidth: $hipWidth, torsoLength: $torsoLength, estimatedHeight: $estimatedHeight)';
}


}

/// @nodoc
abstract mixin class $BodyMeasurementsCopyWith<$Res>  {
  factory $BodyMeasurementsCopyWith(BodyMeasurements value, $Res Function(BodyMeasurements) _then) = _$BodyMeasurementsCopyWithImpl;
@useResult
$Res call({
 double shoulderWidth, double hipWidth, double torsoLength, double estimatedHeight
});




}
/// @nodoc
class _$BodyMeasurementsCopyWithImpl<$Res>
    implements $BodyMeasurementsCopyWith<$Res> {
  _$BodyMeasurementsCopyWithImpl(this._self, this._then);

  final BodyMeasurements _self;
  final $Res Function(BodyMeasurements) _then;

/// Create a copy of BodyMeasurements
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? shoulderWidth = null,Object? hipWidth = null,Object? torsoLength = null,Object? estimatedHeight = null,}) {
  return _then(_self.copyWith(
shoulderWidth: null == shoulderWidth ? _self.shoulderWidth : shoulderWidth // ignore: cast_nullable_to_non_nullable
as double,hipWidth: null == hipWidth ? _self.hipWidth : hipWidth // ignore: cast_nullable_to_non_nullable
as double,torsoLength: null == torsoLength ? _self.torsoLength : torsoLength // ignore: cast_nullable_to_non_nullable
as double,estimatedHeight: null == estimatedHeight ? _self.estimatedHeight : estimatedHeight // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [BodyMeasurements].
extension BodyMeasurementsPatterns on BodyMeasurements {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BodyMeasurements value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BodyMeasurements() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BodyMeasurements value)  $default,){
final _that = this;
switch (_that) {
case _BodyMeasurements():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BodyMeasurements value)?  $default,){
final _that = this;
switch (_that) {
case _BodyMeasurements() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double shoulderWidth,  double hipWidth,  double torsoLength,  double estimatedHeight)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BodyMeasurements() when $default != null:
return $default(_that.shoulderWidth,_that.hipWidth,_that.torsoLength,_that.estimatedHeight);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double shoulderWidth,  double hipWidth,  double torsoLength,  double estimatedHeight)  $default,) {final _that = this;
switch (_that) {
case _BodyMeasurements():
return $default(_that.shoulderWidth,_that.hipWidth,_that.torsoLength,_that.estimatedHeight);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double shoulderWidth,  double hipWidth,  double torsoLength,  double estimatedHeight)?  $default,) {final _that = this;
switch (_that) {
case _BodyMeasurements() when $default != null:
return $default(_that.shoulderWidth,_that.hipWidth,_that.torsoLength,_that.estimatedHeight);case _:
  return null;

}
}

}

/// @nodoc


class _BodyMeasurements implements BodyMeasurements {
  const _BodyMeasurements({required this.shoulderWidth, required this.hipWidth, required this.torsoLength, required this.estimatedHeight});
  

@override final  double shoulderWidth;
@override final  double hipWidth;
@override final  double torsoLength;
@override final  double estimatedHeight;

/// Create a copy of BodyMeasurements
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BodyMeasurementsCopyWith<_BodyMeasurements> get copyWith => __$BodyMeasurementsCopyWithImpl<_BodyMeasurements>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BodyMeasurements&&(identical(other.shoulderWidth, shoulderWidth) || other.shoulderWidth == shoulderWidth)&&(identical(other.hipWidth, hipWidth) || other.hipWidth == hipWidth)&&(identical(other.torsoLength, torsoLength) || other.torsoLength == torsoLength)&&(identical(other.estimatedHeight, estimatedHeight) || other.estimatedHeight == estimatedHeight));
}


@override
int get hashCode => Object.hash(runtimeType,shoulderWidth,hipWidth,torsoLength,estimatedHeight);

@override
String toString() {
  return 'BodyMeasurements(shoulderWidth: $shoulderWidth, hipWidth: $hipWidth, torsoLength: $torsoLength, estimatedHeight: $estimatedHeight)';
}


}

/// @nodoc
abstract mixin class _$BodyMeasurementsCopyWith<$Res> implements $BodyMeasurementsCopyWith<$Res> {
  factory _$BodyMeasurementsCopyWith(_BodyMeasurements value, $Res Function(_BodyMeasurements) _then) = __$BodyMeasurementsCopyWithImpl;
@override @useResult
$Res call({
 double shoulderWidth, double hipWidth, double torsoLength, double estimatedHeight
});




}
/// @nodoc
class __$BodyMeasurementsCopyWithImpl<$Res>
    implements _$BodyMeasurementsCopyWith<$Res> {
  __$BodyMeasurementsCopyWithImpl(this._self, this._then);

  final _BodyMeasurements _self;
  final $Res Function(_BodyMeasurements) _then;

/// Create a copy of BodyMeasurements
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? shoulderWidth = null,Object? hipWidth = null,Object? torsoLength = null,Object? estimatedHeight = null,}) {
  return _then(_BodyMeasurements(
shoulderWidth: null == shoulderWidth ? _self.shoulderWidth : shoulderWidth // ignore: cast_nullable_to_non_nullable
as double,hipWidth: null == hipWidth ? _self.hipWidth : hipWidth // ignore: cast_nullable_to_non_nullable
as double,torsoLength: null == torsoLength ? _self.torsoLength : torsoLength // ignore: cast_nullable_to_non_nullable
as double,estimatedHeight: null == estimatedHeight ? _self.estimatedHeight : estimatedHeight // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
