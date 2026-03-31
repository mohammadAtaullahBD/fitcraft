import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitcraft/core/utils/theme.dart';
import 'package:fitcraft/features/scan/presentation/measurement_cards.dart';
import 'package:fitcraft/features/scan/presentation/scan_feedback.dart';
import 'package:fitcraft/features/scan/presentation/scan_strings.dart';
import 'package:fitcraft/features/scan/state/body_scan_notifier.dart';

class MeasurementsPreviewScreen extends ConsumerWidget {
  const MeasurementsPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bodyScanNotifierProvider);
    final measurements = state.measurements;

    return Scaffold(
      appBar: AppBar(
        title: const Text(ScanStrings.previewTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: measurements == null
          ? const Center(
              child: Text(
                ScanStrings.noMeasurements,
                style: TextStyle(color: Colors.white),
              ),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDescription(),
                    const SizedBox(height: 32),
                    _buildMeasurementGrid(measurements),
                    const SizedBox(height: 24),
                    _buildRetakeButton(context, ref),
                    const SizedBox(height: 16),
                    _buildContinueButton(context),
                  ],
                ),
              ),
            ),
    );
  }

  /// Builds the descriptive text shown above the measurement grid.
  Widget _buildDescription() {
    return const Text(
      ScanStrings.previewDescription,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 16,
      ),
    );
  }

  /// Builds the grid of estimated body measurements.
  Widget _buildMeasurementGrid(dynamic measurements) {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
        children: [
          MeasurementCard(
            label: ScanStrings.heightLabel,
            value: '${measurements.estimatedHeight}',
            icon: Icons.height,
          ),
          MeasurementCard(
            label: ScanStrings.torsoLabel,
            value: '${measurements.torsoLength}',
            icon: Icons.accessibility,
          ),
          MeasurementCard(
            label: ScanStrings.shoulderLabel,
            value: '${measurements.shoulderWidth}',
            icon: Icons.straighten,
          ),
          MeasurementCard(
            label: ScanStrings.hipLabel,
            value: '${measurements.hipWidth}',
            icon: Icons.horizontal_rule,
          ),
        ],
      ),
    );
  }

  /// Builds the button that resets the current scan and returns to capture.
  Widget _buildRetakeButton(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: AppTheme.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: () => _retakePhotos(context, ref),
      child: const Text(
        ScanStrings.retakePhotos,
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  /// Builds the button that advances past the measurement preview.
  Widget _buildContinueButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () => _handleContinue(context),
        child: const Text(
          ScanStrings.continueLabel,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  /// Resets the current scan state and returns to the camera flow.
  void _retakePhotos(BuildContext context, WidgetRef ref) {
    ref.read(bodyScanNotifierProvider.notifier).reset();
    context.pop();
  }

  /// Shows a temporary success state until persistence is implemented.
  void _handleContinue(BuildContext context) {
    showScanMessage(context, ScanStrings.saveSuccess);
  }
}
