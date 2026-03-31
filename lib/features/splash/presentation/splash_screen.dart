import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fitcraft/app/router.dart';
import 'package:fitcraft/core/utils/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Wait for the GIF animation to play for a distinct duration
    await Future.delayed(const Duration(milliseconds: 2800));
    
    // Safely navigate away to the login route. The router's
    // redirect guard will automatically send the user to the
    // dashboard if they are already authenticated!
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Image.asset(
          'assets/images/splash_image.gif',
          width: 100, // Reduced from 250 to make it smaller and sharper
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
