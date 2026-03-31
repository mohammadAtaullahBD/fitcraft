import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitcraft/app/router.dart';
import 'package:fitcraft/core/utils/theme.dart';
import 'package:fitcraft/features/splash/presentation/splash_strings.dart';
import 'package:fitcraft/features/splash/state/splash_navigation_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(splashDelayProvider, (_, next) {
      next.whenOrNull(
        data: (_) => context.go(AppRoutes.login),
      );
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Image.asset(
          SplashStrings.splashAssetPath,
          width: SplashStrings.splashImageWidth,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
