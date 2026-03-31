import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitcraft/app/router.dart';
import 'package:fitcraft/core/utils/theme.dart';
import 'package:fitcraft/features/scan/state/body_scan_notifier.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInit = false;
  
  XFile? _frontPhoto;
  bool _takingSidePhoto = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No camera found on this device.')),
        );
      }
      return;
    }

    // Default to front camera if available, otherwise fallback.
    final frontCamera = _cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras.first,
    );

    _controller = CameraController(
      frontCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (!mounted) return;
      
      // Ensure the flash is off for consistency 
      await _controller!.setFlashMode(FlashMode.off);

      setState(() => _isInit = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize camera: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isTakingPicture) return;

    try {
      final photo = await _controller!.takePicture();
      
      if (_frontPhoto == null) {
        // Front photo captured, transition to side photo instructions
        setState(() {
          _frontPhoto = photo;
          _takingSidePhoto = true;
        });
      } else {
        // Both captured. Trigger analysis!
        final success = await ref.read(bodyScanNotifierProvider.notifier).startAnalysis(
          frontPhoto: _frontPhoto!,
          sidePhoto: photo,
        );
        
        if (!mounted) return;
        
        if (success) {
           context.push(AppRoutes.scanPreview);
        } else {
           // If it failed, the error state is saved in the notifier. Reset UI state.
           setState(() {
             _frontPhoto = null;
             _takingSidePhoto = false;
           });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to take photo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(bodyScanNotifierProvider);
    
    // Listen for error messages inside the body scan notifier
    ref.listen(bodyScanNotifierProvider, (previous, next) {
      if (next.error != null && (previous?.error != next.error)) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(next.error!), backgroundColor: AppTheme.error),
        );
      }
    });

    if (!_isInit || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Preview
          CameraPreview(_controller!),
          
          // 2. Translucent Overlay with silhouette/instructions
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    _takingSidePhoto 
                      ? 'Turn to face left or right.\nEnsure full body is in frame.'
                      : 'Face forward.\nEnsure full body is in frame.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Alignment Silhouette (Mockup)
                Icon(
                  _takingSidePhoto ? Icons.accessibility_new : Icons.accessibility,
                  size: 300,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                
                const Spacer(),
                
                // Capture Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: scanState.isScanning
                    ? const CircularProgressIndicator(color: AppTheme.primary)
                    : GestureDetector(
                        onTap: _capturePhoto,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            color: AppTheme.primary.withValues(alpha: 0.8),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
