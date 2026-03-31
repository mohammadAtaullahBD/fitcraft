import 'package:fitcraft/features/scan/domain/body_scan_constants.dart';
import 'package:fitcraft/features/scan/domain/body_scan_service.dart';

/// Maps scan-analysis failures into user-facing error messages.
String mapBodyScanError(Object error) {
  if (error is BodyScanException) {
    return error.message;
  }

  return BodyScanConstants.genericProcessingFailurePrefix;
}
