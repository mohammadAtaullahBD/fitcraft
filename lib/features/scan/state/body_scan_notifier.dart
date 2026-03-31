import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitcraft/features/scan/domain/body_measurements.dart';
import 'package:fitcraft/features/scan/domain/body_scan_service.dart';
import 'package:fitcraft/features/scan/state/body_scan_error_mapper.dart';

/// Provides a shared body-scan service instance for scan workflows.
final bodyScanServiceProvider = Provider<BodyScanService>((ref) {
  final service = BodyScanService();
  ref.onDispose(service.dispose);
  return service;
});

class BodyScanState {
  final bool isScanning;
  final BodyMeasurements? measurements;
  final String? error;

  const BodyScanState({
    this.isScanning = false,
    this.measurements,
    this.error,
  });

  /// Creates a new state with updated scan status and result values.
  BodyScanState copyWith({
    bool? isScanning,
    BodyMeasurements? measurements,
    String? error,
  }) {
    return BodyScanState(
      isScanning: isScanning ?? this.isScanning,
      measurements: measurements ?? this.measurements,
      error: error,
    );
  }
}

class BodyScanNotifier extends Notifier<BodyScanState> {
  @override
  BodyScanState build() => const BodyScanState();

  /// Runs body-measurement analysis for a captured front and side photo.
  Future<bool> startAnalysis({
    required XFile frontPhoto,
    required XFile sidePhoto,
  }) async {
    state = state.copyWith(isScanning: true, error: null);

    try {
      final service = ref.read(bodyScanServiceProvider);
      final results = await service.processPhotos(
        frontPhoto: frontPhoto,
        sidePhoto: sidePhoto,
      );

      state = state.copyWith(
        isScanning: false,
        measurements: results,
        error: null,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isScanning: false,
        error: mapBodyScanError(error),
      );
      return false;
    }
  }

  /// Resets the scan flow back to its initial empty state.
  void reset() {
    state = const BodyScanState();
  }
}

final bodyScanNotifierProvider =
    NotifierProvider<BodyScanNotifier, BodyScanState>(BodyScanNotifier.new);
