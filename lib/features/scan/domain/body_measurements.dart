import 'package:freezed_annotation/freezed_annotation.dart';

part 'body_measurements.freezed.dart';

@freezed
abstract class BodyMeasurements with _$BodyMeasurements {
  /// Creates an immutable set of estimated body measurements in centimeters.
  const factory BodyMeasurements({
    required double shoulderWidth,
    required double hipWidth,
    required double torsoLength,
    required double estimatedHeight,
  }) = _BodyMeasurements;
}
