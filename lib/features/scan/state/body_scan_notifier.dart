import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitcraft/features/scan/domain/body_measurements.dart';
import 'package:fitcraft/features/scan/domain/body_scan_service.dart';

/// Provides a global instance of BodyScanService
final bodyScanServiceProvider = Provider<BodyScanService>((ref) {
  final service = BodyScanService();
  ref.onDispose(() => service.dispose());
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
  
  BodyScanState copyWith({
    bool? isScanning,
    BodyMeasurements? measurements,
    String? error,
  }) {
    return BodyScanState(
      isScanning: isScanning ?? this.isScanning,
      measurements: measurements ?? this.measurements,
      error: error, // Can deliberately nullify error
    );
  }
}

class BodyScanNotifier extends Notifier<BodyScanState> {
  @override
  BodyScanState build() => const BodyScanState();

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
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void reset() {
    state = const BodyScanState();
  }
}

final bodyScanNotifierProvider = NotifierProvider<BodyScanNotifier, BodyScanState>(() {
  return BodyScanNotifier();
});
