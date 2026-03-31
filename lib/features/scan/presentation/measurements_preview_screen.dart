import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitcraft/core/utils/theme.dart';
import 'package:fitcraft/features/scan/state/body_scan_notifier.dart';

class MeasurementsPreviewScreen extends ConsumerWidget {
  const MeasurementsPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bodyScanNotifierProvider);
    final measurements = state.measurements;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Scan Results'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, 
      ),
      body: measurements == null
          ? const Center(child: Text('No measurements available.', style: TextStyle(color: Colors.white)))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Based on your photos, here are your estimated physical measurements.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                    ),
                    const SizedBox(height: 32),
                    
                    // Grid of 4 measurement cards
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2,
                        children: [
                          _MeasurementCard(
                            label: 'Height',
                            value: '${measurements.estimatedHeight}',
                            icon: Icons.height,
                          ),
                          _MeasurementCard(
                            label: 'Torso',
                            value: '${measurements.torsoLength}',
                            icon: Icons.accessibility,
                          ),
                          _MeasurementCard(
                            label: 'Shoulder',
                            value: '${measurements.shoulderWidth}',
                            icon: Icons.straighten,
                          ),
                          _MeasurementCard(
                            label: 'Hip',
                            value: '${measurements.hipWidth}',
                            icon: Icons.horizontal_rule,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Actions
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppTheme.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        // Reset state and pop back to camera
                        ref.read(bodyScanNotifierProvider.notifier).reset();
                        context.pop();
                      },
                      child: const Text('Retake Photos', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 16),
                    Container(
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
                        onPressed: () {
                          // TODO: Save to DB or route to Avatar screen 
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Measurements Saved! (Mock)')),
                          );
                        },
                        child: const Text('Looks Good, Continue', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _MeasurementCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MeasurementCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.primary, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'cm',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
