import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitcraft/features/splash/presentation/splash_strings.dart';

/// Waits for the splash duration before allowing navigation onward.
final splashDelayProvider = FutureProvider<void>((ref) async {
  await Future<void>.delayed(
    const Duration(milliseconds: SplashStrings.splashDelayMilliseconds),
  );
});
