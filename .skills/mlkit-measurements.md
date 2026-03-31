---
name: mlkit-measurements
description: "Use this skill whenever FitCraft extracts body measurements from a photo. Triggers: BodyScanService, google_mlkit_pose_detection, any reference to '33 landmarks', 'shoulder width', 'hip width', 'body measurements', or 'pose detection'. Covers landmark index mapping, pixel-to-cm conversion, and confidence thresholds."
---

# FitCraft — ML Kit Body Measurements

## The 33 Landmark Indices (PoseLandmarkType)

These are the exact landmark indices used by `google_mlkit_pose_detection`. Always reference by name, not raw index.

| Body Part | Landmark Name | Index |
|-----------|--------------|-------|
| Nose | `nose` | 0 |
| Left eye inner | `leftEyeInner` | 1 |
| Left eye | `leftEye` | 2 |
| Left eye outer | `leftEyeOuter` | 3 |
| Right eye inner | `rightEyeInner` | 4 |
| Right eye | `rightEye` | 5 |
| Right eye outer | `rightEyeOuter` | 6 |
| Left ear | `leftEar` | 7 |
| Right ear | `rightEar` | 8 |
| Left mouth | `leftMouth` | 9 |
| Right mouth | `rightMouth` | 10 |
| **Left shoulder** | `leftShoulder` | 11 |
| **Right shoulder** | `rightShoulder` | 12 |
| Left elbow | `leftElbow` | 13 |
| Right elbow | `rightElbow` | 14 |
| Left wrist | `leftWrist` | 15 |
| Right wrist | `rightWrist` | 16 |
| Left pinky | `leftPinky` | 17 |
| Right pinky | `rightPinky` | 18 |
| Left index | `leftIndex` | 19 |
| Right index | `rightIndex` | 20 |
| Left thumb | `leftThumb` | 21 |
| Right thumb | `rightThumb` | 22 |
| **Left hip** | `leftHip` | 23 |
| **Right hip** | `rightHip` | 24 |
| Left knee | `leftKnee` | 25 |
| Right knee | `rightKnee` | 26 |
| **Left ankle** | `leftAnkle` | 27 |
| **Right ankle** | `rightAnkle` | 28 |
| Left heel | `leftHeel` | 29 |
| Right heel | `rightHeel` | 30 |
| Left foot index | `leftFootIndex` | 31 |
| Right foot index | `rightFootIndex` | 32 |

**Bold = used for FitCraft measurements.**

---

## FitCraft Measurement Formulas

### Shoulder Width
```
Left shoulder (11) ←————————→ Right shoulder (12)
= Euclidean distance(leftShoulder.x, rightShoulder.x)
```

### Hip Width
```
Left hip (23) ←————→ Right hip (24)
= Euclidean distance(leftHip.x, rightHip.x)
```

### Torso Length
```
Shoulder midpoint: ((leftShoulder.x + rightShoulder.x)/2, (leftShoulder.y + rightShoulder.y)/2)
Hip midpoint: ((leftHip.x + rightHip.x)/2, (leftHip.y + rightHip.y)/2)
= Euclidean distance(shoulderMid, hipMid)
```

### Estimated Height
```
Head top: estimated as nose.y - (shoulderMid.y - nose.y) × 0.5  [head above nose]
Foot bottom: (leftAnkle.y + rightAnkle.y) / 2
= |headTop.y - footMid.y|   (vertical only — assumes person standing upright)
```

---

## BodyScanService Full Implementation

```dart
// features/scan/domain/body_scan_service.dart
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'body_measurements.dart';
part 'body_scan_service.g.dart';

@riverpod
BodyScanService bodyScanService(BodyScanServiceRef ref) => BodyScanService();

class BodyScanService {
  final PoseDetector _detector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.single,   // single image, not stream
      model: PoseDetectionModel.accurate,
    ),
  );

  /// Runs pose detection on [photo] and returns body measurements.
  /// Throws [BodyScanException] if detection fails or confidence is too low.
  Future<BodyMeasurements> scan(XFile photo) async {
    final inputImage = InputImage.fromFilePath(photo.path);
    final List<Pose> poses = await _detector.processImage(inputImage);

    if (poses.isEmpty) {
      throw BodyScanException('No body detected in photo. Please stand in full view.');
    }

    final Pose pose = poses.first;
    _debugPrintAllLandmarks(pose);  // Remove in production

    // Validate required landmarks are present and confident
    _validateLandmarks(pose, [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.leftAnkle,
      PoseLandmarkType.rightAnkle,
    ]);

    return _calculateMeasurements(pose);
  }

  BodyMeasurements _calculateMeasurements(Pose pose) {
    final ls = pose.landmarks[PoseLandmarkType.leftShoulder]!;
    final rs = pose.landmarks[PoseLandmarkType.rightShoulder]!;
    final lh = pose.landmarks[PoseLandmarkType.leftHip]!;
    final rh = pose.landmarks[PoseLandmarkType.rightHip]!;
    final la = pose.landmarks[PoseLandmarkType.leftAnkle]!;
    final ra = pose.landmarks[PoseLandmarkType.rightAnkle]!;
    final nose = pose.landmarks[PoseLandmarkType.nose]!;

    // Pixel distances
    final shoulderWidthPx = _dist(ls.x, ls.y, rs.x, rs.y);
    final hipWidthPx       = _dist(lh.x, lh.y, rh.x, rh.y);

    final shoulderMidX = (ls.x + rs.x) / 2;
    final shoulderMidY = (ls.y + rs.y) / 2;
    final hipMidX      = (lh.x + rh.x) / 2;
    final hipMidY      = (lh.y + rh.y) / 2;
    final torsoLengthPx = _dist(shoulderMidX, shoulderMidY, hipMidX, hipMidY);

    // Estimate head top (nose to shoulder distance used as head height proxy)
    final headOffsetPx  = (shoulderMidY - nose.y) * 0.6;
    final headTopY      = nose.y - headOffsetPx;
    final footMidY      = (la.y + ra.y) / 2;
    final heightPx      = (footMidY - headTopY).abs();

    // Convert pixels → cm using the shoulder-width calibration ratio.
    // Real adult shoulder width ≈ 38–48 cm. Use 43 cm as the reference.
    // This self-calibrates to each image's scale without needing device DPI.
    const double referenceShoulderCm = 43.0;
    final double scale = referenceShoulderCm / shoulderWidthPx;

    return BodyMeasurements(
      shoulderWidth:   _round(shoulderWidthPx * scale),
      hipWidth:        _round(hipWidthPx * scale),
      torsoLength:     _round(torsoLengthPx * scale),
      estimatedHeight: _round(heightPx * scale),
    );
  }

  /// Validate landmark confidence. MLKit confidence ≥ 0.5 is reliable.
  void _validateLandmarks(Pose pose, List<PoseLandmarkType> required) {
    for (final type in required) {
      final landmark = pose.landmarks[type];
      if (landmark == null) {
        throw BodyScanException('Missing landmark: $type. Ensure full body is visible.');
      }
      // MLKit InferencePoseLandmark has a likelihood property
      if (landmark.likelihood < 0.5) {
        throw BodyScanException(
          'Low confidence on $type (${landmark.likelihood.toStringAsFixed(2)}). '
          'Try better lighting or a plain background.',
        );
      }
    }
  }

  void _debugPrintAllLandmarks(Pose pose) {
    debugPrint('=== ALL 33 LANDMARKS ===');
    pose.landmarks.forEach((type, landmark) {
      debugPrint(
        '$type → x:${landmark.x.toStringAsFixed(1)} '
        'y:${landmark.y.toStringAsFixed(1)} '
        'z:${landmark.z.toStringAsFixed(1)} '
        'likelihood:${landmark.likelihood.toStringAsFixed(2)}',
      );
    });
    debugPrint('========================');
  }

  double _dist(double x1, double y1, double x2, double y2) =>
      sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2));

  double _round(double value) =>
      double.parse(value.toStringAsFixed(1));

  void dispose() => _detector.close();
}

class BodyScanException implements Exception {
  final String message;
  BodyScanException(this.message);
  @override
  String toString() => 'BodyScanException: $message';
}
```

---

## Pixel-to-CM Conversion Strategy

FitCraft uses **self-calibration via shoulder width** instead of device DPI:

| Approach | Problem |
|----------|---------|
| Device DPI (`MediaQuery.devicePixelRatio`) | Unreliable — varies by distance from camera |
| Fixed constant (e.g. `0.026 cm/px`) | Wrong — depends on how far user stands |
| **Shoulder width reference (FitCraft approach)** | ✅ Self-corrects for any camera distance |

The formula:
```
scale = 43.0 cm / shoulderWidthPixels
allMeasurements × scale → cm values
```

**43.0 cm is the average adult shoulder width.** This is a known limitation — unusually narrow or wide users will have slightly off measurements. Phase 2 can add a height-input field to improve calibration.

---

## Photo Capture Requirements for Accuracy

Tell the user in the UI:
- Stand 2–3 meters from camera
- Full body must be in frame (head to feet)
- Arms slightly away from body
- Plain background preferred
- Good lighting (avoid backlight)
- Front photo first, then side photo

---

## Known Limitations

| Limitation | Impact | Workaround |
|------------|--------|------------|
| 2D landmarks, no depth | Hip/shoulder width may be underestimated if user is angled | Use side photo for chest depth |
| Loose clothing | Landmarks detected on cloth, not body | Instruct form-fitting clothes |
| Shoulder reference assumes 43 cm | ±5 cm error for extreme body types | Add optional manual height input for calibration |
| Z coordinate from MLKit | Unreliable for measurements | Use only X, Y coordinates |
