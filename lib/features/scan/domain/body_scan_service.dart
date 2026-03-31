import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:fitcraft/features/scan/domain/body_measurements.dart';
import 'package:fitcraft/features/scan/domain/body_scan_constants.dart';
import 'package:fitcraft/features/scan/domain/body_scan_geometry.dart';
import 'package:fitcraft/features/scan/domain/body_scan_landmarks.dart';

class BodyScanException implements Exception {
  final String message;

  BodyScanException(this.message);

  @override
  String toString() => message;
}

class BodyScanService {
  final PoseDetector _poseDetector;

  BodyScanService()
      : _poseDetector = PoseDetector(
          options: PoseDetectorOptions(
            model: PoseDetectionModel.base,
            mode: PoseDetectionMode.single,
          ),
        );

  /// Performs pose detection and returns estimated body measurements.
  Future<BodyMeasurements> processPhotos({
    required XFile frontPhoto,
    required XFile sidePhoto,
  }) async {
    try {
      final frontPose = await _extractFrontPose(frontPhoto);
      _debugLogPoseLandmarks(frontPose);
      validateRequiredBodyScanLandmarks(frontPose);
      return _buildMeasurements(frontPose, sidePhoto.path);
    } catch (error) {
      if (error is BodyScanException) rethrow;
      throw BodyScanException(
        '${BodyScanConstants.genericProcessingFailurePrefix} $error',
      );
    }
  }

  /// Releases the underlying ML Kit detector resources.
  void dispose() {
    _poseDetector.close();
  }

  /// Extracts the primary front-facing pose from the provided photo.
  Future<Pose> _extractFrontPose(XFile frontPhoto) async {
    final inputImage = InputImage.fromFilePath(frontPhoto.path);
    final poses = await _poseDetector.processImage(inputImage);

    if (poses.isEmpty) {
      throw BodyScanException(BodyScanConstants.noPersonDetectedMessage);
    }

    return poses.first;
  }

  /// Logs all detected pose landmarks during debug builds.
  void _debugLogPoseLandmarks(Pose pose) {
    if (!kDebugMode) return;

    debugPrint('--- RAW 33 POSE LANDMARKS ---');
    for (final entry in pose.landmarks.entries) {
      final landmark = entry.value;
      debugPrint(
        '${entry.key.name}: '
        'x=${landmark.x.toStringAsFixed(1)}, '
        'y=${landmark.y.toStringAsFixed(1)}, '
        'z=${landmark.z.toStringAsFixed(1)}, '
        'likelihood=${landmark.likelihood}',
      );
    }
    debugPrint('-----------------------------');
  }

  /// Builds the final body-measurement model from a validated pose.
  BodyMeasurements _buildMeasurements(Pose pose, String sidePhotoPath) {
    final leftShoulder =
        requiredBodyScanLandmark(pose, PoseLandmarkType.leftShoulder);
    final rightShoulder =
        requiredBodyScanLandmark(pose, PoseLandmarkType.rightShoulder);
    final leftHip = requiredBodyScanLandmark(pose, PoseLandmarkType.leftHip);
    final rightHip = requiredBodyScanLandmark(pose, PoseLandmarkType.rightHip);
    final nose = requiredBodyScanLandmark(pose, PoseLandmarkType.nose);
    final leftAnkle =
        requiredBodyScanLandmark(pose, PoseLandmarkType.leftAnkle);
    final rightAnkle =
        requiredBodyScanLandmark(pose, PoseLandmarkType.rightAnkle);

    final shoulderPixelWidth =
        distanceBetweenLandmarks(leftShoulder, rightShoulder);
    final hipPixelWidth = distanceBetweenLandmarks(leftHip, rightHip);
    final torsoPixelLength = _calculateTorsoLength(
      leftShoulder,
      rightShoulder,
      leftHip,
      rightHip,
    );
    final estimatedPixelHeight = _calculateEstimatedPixelHeight(
      nose: nose,
      leftShoulder: leftShoulder,
      rightShoulder: rightShoulder,
      leftAnkle: leftAnkle,
      rightAnkle: rightAnkle,
    );
    final pixelToCmRatio = _pixelToCmRatio(estimatedPixelHeight, sidePhotoPath);

    return BodyMeasurements(
      shoulderWidth: _roundMeasurement(shoulderPixelWidth * pixelToCmRatio),
      hipWidth: _roundMeasurement(hipPixelWidth * pixelToCmRatio),
      torsoLength: _roundMeasurement(torsoPixelLength * pixelToCmRatio),
      estimatedHeight: _roundMeasurement(estimatedPixelHeight * pixelToCmRatio),
    );
  }

  /// Calculates torso length using shoulder and hip midpoints.
  double _calculateTorsoLength(
    PoseLandmark leftShoulder,
    PoseLandmark rightShoulder,
    PoseLandmark leftHip,
    PoseLandmark rightHip,
  ) {
    final midShoulder = midpointBetweenLandmarks(leftShoulder, rightShoulder);
    final midHip = midpointBetweenLandmarks(leftHip, rightHip);
    return distanceBetweenPoints(midShoulder, midHip);
  }

  /// Estimates full body height from head-top heuristic to ankle midpoint.
  double _calculateEstimatedPixelHeight({
    required PoseLandmark nose,
    required PoseLandmark leftShoulder,
    required PoseLandmark rightShoulder,
    required PoseLandmark leftAnkle,
    required PoseLandmark rightAnkle,
  }) {
    final shoulderWidth = distanceBetweenLandmarks(leftShoulder, rightShoulder);
    final headTopY = nose.y -
        (shoulderWidth * BodyScanConstants.headTopOffsetFromShoulderRatio);
    final ankleMidpoint = midpointBetweenLandmarks(leftAnkle, rightAnkle);
    return (ankleMidpoint.y - headTopY).abs();
  }

  /// Converts pixel units into approximate centimeters using a heuristic scale.
  double _pixelToCmRatio(double estimatedPixelHeight, String sidePhotoPath) {
    if (kDebugMode) {
      debugPrint('Side photo captured for future processing: $sidePhotoPath');
    }

    return BodyScanConstants.defaultEstimatedHeightCm / estimatedPixelHeight;
  }

  /// Rounds a measurement to the configured precision.
  double _roundMeasurement(double value) {
    return double.parse(
      value.toStringAsFixed(BodyScanConstants.measurementPrecisionDigits),
    );
  }
}
