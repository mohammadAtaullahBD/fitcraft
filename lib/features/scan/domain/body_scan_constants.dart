/// Constants for body scan heuristics and user-facing messages.
class BodyScanConstants {
  BodyScanConstants._();

  static const double defaultEstimatedHeightCm = 170.0;
  static const double headTopOffsetFromShoulderRatio = 0.4;
  static const int measurementPrecisionDigits = 1;

  static const String noPersonDetectedMessage =
      'No person detected in the photo. Please ensure your full body is visible.';

  static const String missingLandmarksMessage =
      'Could not clearly see all necessary body parts. Please step back and ensure you are well-lit.';

  static const String cameraUnavailableMessage =
      'No camera found on this device.';

  static const String photoCaptureFailedPrefix = 'Failed to take photo:';
  static const String cameraInitFailedPrefix = 'Failed to initialize camera:';
  static const String genericProcessingFailurePrefix = 'Failed to process image:';
}
