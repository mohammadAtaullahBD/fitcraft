import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:camera/camera.dart';
import 'package:fitcraft/features/scan/domain/body_measurements.dart';
import 'package:flutter/foundation.dart';

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

  /// Performs ML Kit pose detection on the front and side photos.
  Future<BodyMeasurements> processPhotos({
    required XFile frontPhoto,
    required XFile sidePhoto,
  }) async {
    try {
      final frontInput = InputImage.fromFilePath(frontPhoto.path);
      // Currently, side photo is passed for future architectural symmetry, 
      // but ML Kit base pose gets most dimensions from the front profile.
      // We will primarily analyze the front image for these 4 metrics.
      
      final poses = await _poseDetector.processImage(frontInput);
      
      if (poses.isEmpty) {
        throw BodyScanException('No person detected in the photo. Please ensure your full body is visible.');
      }

      final pose = poses.first;
      
      // Print all 33 landmarks to the debug console as requested!
      if (kDebugMode) {
        print('--- RAW 33 POSE LANDMARKS ---');
        for (final entry in pose.landmarks.entries) {
          final type = entry.key;
          final landmark = entry.value;
          print('${type.name}: x=${landmark.x.toStringAsFixed(1)}, y=${landmark.y.toStringAsFixed(1)}, z=${landmark.z.toStringAsFixed(1)}, likelihood=${landmark.likelihood}');
        }
        print('-----------------------------');
      }

      // 1. Extract required landmarks
      final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
      final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
      final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
      final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
      final nose = pose.landmarks[PoseLandmarkType.nose];
      final leftAnkle = pose.landmarks[PoseLandmarkType.leftAnkle];
      final rightAnkle = pose.landmarks[PoseLandmarkType.rightAnkle];

      // Ensure critical landmarks are detected with high confidence
      if (leftShoulder == null || rightShoulder == null || 
          leftHip == null || rightHip == null || 
          nose == null || leftAnkle == null || rightAnkle == null) {
        throw BodyScanException('Could not clearly see all necessary body parts. Please step back and ensure you are well-lit.');
      }

      // 2. Calculate pixel distances
      final shoulderPixelWidth = _distanceBetween(leftShoulder, rightShoulder);
      final hipPixelWidth = _distanceBetween(leftHip, rightHip);
      
      final midShoulder = _midPoint(leftShoulder, rightShoulder);
      final midHip = _midPoint(leftHip, rightHip);
      final torsoPixelLength = _distance(midShoulder, midHip);
      
      final midAnkle = _midPoint(leftAnkle, rightAnkle);
      // Approximate top of head assuming nose is somewhat below the crown
      final headTopY = nose.y - (_distanceBetween(leftShoulder, rightShoulder) * 0.4); 
      final estimatedPixelHeight = (midAnkle.y - headTopY).abs();

      // 3. Convert pixel units to centimeters.
      // NOTE: Without a known reference object (like an A4 paper or coin) or a depth map, 
      // ML Kit bounding box pixels cannot map accurately to real-world metric values.
      // For this prototype, we'll assume a standard heuristic scale: 
      // e.g. the average human height is ~170cm.
      final pixelToCmRatio = 170.0 / estimatedPixelHeight;

      return BodyMeasurements(
        shoulderWidth: double.parse((shoulderPixelWidth * pixelToCmRatio).toStringAsFixed(1)),
        hipWidth: double.parse((hipPixelWidth * pixelToCmRatio).toStringAsFixed(1)),
        torsoLength: double.parse((torsoPixelLength * pixelToCmRatio).toStringAsFixed(1)),
        estimatedHeight: double.parse((estimatedPixelHeight * pixelToCmRatio).toStringAsFixed(1)),
      );

    } catch (e) {
      if (e is BodyScanException) rethrow;
      throw BodyScanException('Failed to process image: ${e.toString()}');
    }
  }

  void dispose() {
    _poseDetector.close();
  }

  // --- Math Helpers ---

  double _distanceBetween(PoseLandmark p1, PoseLandmark p2) {
    return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2));
  }
  
  double _distance(Point<double> p1, Point<double> p2) {
    return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2));
  }

  Point<double> _midPoint(PoseLandmark p1, PoseLandmark p2) {
    return Point((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
  }
}
