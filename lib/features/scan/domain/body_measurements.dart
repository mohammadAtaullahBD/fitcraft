import 'package:freezed_annotation/freezed_annotation.dart';

part 'body_measurements.freezed.dart';

@freezed
class BodyMeasurements with _$BodyMeasurements {
  const factory BodyMeasurements({
    /// Shoulder width (left shoulder to right shoulder) in cm
    required double shoulderWidth,

    /// Hip width (left hip to right hip) in cm
    required double hipWidth,

    /// Torso length (shoulder midpoint to hip midpoint) in cm
    required double torsoLength,

    /// Estimated total height (top of head to ankle midpoint) in cm
    required double estimatedHeight,
  }) = _BodyMeasurements;
}
