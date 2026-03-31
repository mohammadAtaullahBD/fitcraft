import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:fitcraft/features/scan/domain/body_scan_constants.dart';
import 'package:fitcraft/features/scan/domain/body_scan_service.dart';

/// Validates that the required body-scan landmarks exist on a pose.
void validateRequiredBodyScanLandmarks(Pose pose) {
  final requiredLandmarks = [
    PoseLandmarkType.leftShoulder,
    PoseLandmarkType.rightShoulder,
    PoseLandmarkType.leftHip,
    PoseLandmarkType.rightHip,
    PoseLandmarkType.nose,
    PoseLandmarkType.leftAnkle,
    PoseLandmarkType.rightAnkle,
  ];

  final hasAllLandmarks = requiredLandmarks
      .every((type) => pose.landmarks[type] != null);

  if (!hasAllLandmarks) {
    throw BodyScanException(BodyScanConstants.missingLandmarksMessage);
  }
}

/// Returns a required landmark or throws if it is missing.
PoseLandmark requiredBodyScanLandmark(Pose pose, PoseLandmarkType type) {
  final landmark = pose.landmarks[type];
  if (landmark == null) {
    throw BodyScanException(BodyScanConstants.missingLandmarksMessage);
  }
  return landmark;
}
