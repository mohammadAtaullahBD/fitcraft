import 'package:flutter/material.dart';
import 'package:fitcraft/core/utils/theme.dart';

class CameraInstructionBanner extends StatelessWidget {
  final String instruction;

  const CameraInstructionBanner({super.key, required this.instruction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        instruction,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class CaptureButton extends StatelessWidget {
  final VoidCallback onTap;

  const CaptureButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
    );
  }
}
