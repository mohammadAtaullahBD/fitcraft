import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitcraft/app/router.dart';
import 'package:fitcraft/core/utils/theme.dart';
import 'package:fitcraft/features/scan/domain/body_scan_constants.dart';
import 'package:fitcraft/features/scan/presentation/camera_strings.dart';
import 'package:fitcraft/features/scan/presentation/camera_widgets.dart';
import 'package:fitcraft/features/scan/presentation/scan_feedback.dart';
import 'package:fitcraft/features/scan/state/body_scan_notifier.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  XFile? _frontPhoto;
  bool _takingSidePhoto = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Initializes the preferred device camera for the scan flow.
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      _showMessage(BodyScanConstants.cameraUnavailableMessage);
      return;
    }

    final controller = CameraController(
      _selectPreferredCamera(cameras),
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);
      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _isInitialized = true;
      });
    } catch (error) {
      await controller.dispose();
      _showMessage('${BodyScanConstants.cameraInitFailedPrefix} $error');
    }
  }

  /// Selects the front-facing camera when available.
  CameraDescription _selectPreferredCamera(List<CameraDescription> cameras) {
    return cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
  }

  /// Captures the current photo and advances or analyzes the scan flow.
  Future<void> _capturePhoto() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isTakingPicture) return;

    try {
      final photo = await controller.takePicture();
      if (_frontPhoto == null) {
        _storeFrontPhoto(photo);
        return;
      }

      await _analyzeCapturedPhotos(photo);
    } catch (error) {
      _showMessage('${BodyScanConstants.photoCaptureFailedPrefix} $error');
    }
  }

  /// Stores the first captured image and switches the UI to side-photo mode.
  void _storeFrontPhoto(XFile photo) {
    setState(() {
      _frontPhoto = photo;
      _takingSidePhoto = true;
    });
  }

  /// Runs scan analysis using the captured front and side photos.
  Future<void> _analyzeCapturedPhotos(XFile sidePhoto) async {
    final frontPhoto = _frontPhoto;
    if (frontPhoto == null) return;

    final success = await ref.read(bodyScanNotifierProvider.notifier).startAnalysis(
          frontPhoto: frontPhoto,
          sidePhoto: sidePhoto,
        );

    if (!mounted) return;
    if (success) {
      context.push(AppRoutes.scanPreview);
      return;
    }

    setState(() {
      _frontPhoto = null;
      _takingSidePhoto = false;
    });
  }

  /// Displays a scan-related message to the user.
  void _showMessage(String message) {
    if (!mounted) return;
    showScanMessage(context, message);
  }

  /// Shows analysis errors emitted by the scan notifier.
  void _listenForScanErrors() {
    ref.listen(bodyScanNotifierProvider, (previous, next) {
      if (next.error == null || previous?.error == next.error) return;
      showScanError(context, next.error!);
    });
  }

  @override
  Widget build(BuildContext context) {
    _listenForScanErrors();
    final scanState = ref.watch(bodyScanNotifierProvider);

    if (!_isInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 32),
                CameraInstructionBanner(
                  instruction: _takingSidePhoto
                      ? CameraStrings.sideInstruction
                      : CameraStrings.frontInstruction,
                ),
                const Spacer(),
                Icon(
                  _takingSidePhoto
                      ? Icons.accessibility_new
                      : Icons.accessibility,
                  size: 300,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: scanState.isScanning
                      ? const CircularProgressIndicator(
                          color: AppTheme.primary,
                        )
                      : CaptureButton(onTap: _capturePhoto),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
