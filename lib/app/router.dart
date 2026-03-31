import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitcraft/features/auth/state/auth_provider.dart';
import 'package:fitcraft/features/auth/presentation/login_screen.dart';
import 'package:fitcraft/features/auth/presentation/signup_screen.dart';
import 'package:fitcraft/features/auth/presentation/forgot_password_screen.dart';
import 'package:fitcraft/features/scan/presentation/scan_screen.dart';
import 'package:fitcraft/features/scan/presentation/camera_screen.dart';
import 'package:fitcraft/features/scan/presentation/measurements_preview_screen.dart';
import 'package:fitcraft/features/avatar/presentation/avatar_screen.dart';
import 'package:fitcraft/features/store/presentation/store_screen.dart';
import 'package:fitcraft/features/order/presentation/order_screen.dart';
import 'package:fitcraft/features/designer/presentation/designer_screen.dart';
import 'package:fitcraft/features/splash/presentation/splash_screen.dart';
import 'package:fitcraft/app/home_shell.dart';

/// Route names — use these everywhere instead of raw paths.
class AppRoutes {
  AppRoutes._();

  // Intro
  static const String splash = '/splash';

  // Auth
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // Main
  static const String home = '/';
  
  // Scan Flow
  static const String scan = '/scan';
  static const String scanCamera = '/scan/camera';
  static const String scanPreview = '/scan/preview';

  static const String avatar = '/avatar';
  static const String store = '/store';
  static const String order = '/order';
  static const String designer = '/designer';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter configuration provider.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash, // Start at splash screen!
    redirect: (context, state) {
      if (authState.isLoading) return null; // Wait for initial state
      
      final isSplashRoute = state.uri.path == AppRoutes.splash;
      
      // Allow the splash screen to play its animation and dictate next flow
      if (isSplashRoute) return null;
      
      final isAuthenticated = authState.valueOrNull != null;
      final isAuthRoute = state.uri.path == AppRoutes.login ||
                          state.uri.path == AppRoutes.signup ||
                          state.uri.path == AppRoutes.forgotPassword;

      if (!isAuthenticated && !isAuthRoute) {
        return AppRoutes.login;
      }
      
      if (isAuthenticated && isAuthRoute) {
        return AppRoutes.home;
      }
      
      return null;
    },
    routes: [
      // ─── Splash Route ────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ─── Auth Routes ─────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot_password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ─── Protected Routes (Shell) ────────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ScanScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.scan,
            name: 'scan',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ScanScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.store,
            name: 'store',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StoreScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.order,
            name: 'order',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OrderScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.designer,
            name: 'designer',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DesignerScreen(),
            ),
          ),
        ],
      ),
      // Full-screen protected routes (outside the shell)
      GoRoute(
        path: AppRoutes.scanCamera,
        name: 'scan_camera',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CameraScreen(),
      ),
      GoRoute(
        path: AppRoutes.scanPreview,
        name: 'scan_preview',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MeasurementsPreviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.avatar,
        name: 'avatar',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AvatarScreen(),
      ),
    ],
  );
});
