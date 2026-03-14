import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitcraft/features/scan/presentation/scan_screen.dart';
import 'package:fitcraft/features/avatar/presentation/avatar_screen.dart';
import 'package:fitcraft/features/store/presentation/store_screen.dart';
import 'package:fitcraft/features/order/presentation/order_screen.dart';
import 'package:fitcraft/features/designer/presentation/designer_screen.dart';
import 'package:fitcraft/app/home_shell.dart';

/// Route names — use these everywhere instead of raw paths.
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String scan = '/scan';
  static const String avatar = '/avatar';
  static const String store = '/store';
  static const String order = '/order';
  static const String designer = '/designer';
}

/// GoRouter configuration provider.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      ShellRoute(
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
      // Full-screen routes (outside the shell)
      GoRoute(
        path: AppRoutes.avatar,
        name: 'avatar',
        builder: (context, state) => const AvatarScreen(),
      ),
    ],
  );
});
