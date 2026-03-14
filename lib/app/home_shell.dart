import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fitcraft/app/router.dart';
import 'package:fitcraft/core/utils/theme.dart';

/// Shell widget providing bottom navigation across main tabs.
class HomeShell extends StatelessWidget {
  final Widget child;

  const HomeShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(AppRoutes.store)) return 1;
    if (location.startsWith(AppRoutes.order)) return 2;
    if (location.startsWith(AppRoutes.designer)) return 3;
    return 0; // scan / home
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border(
            top: BorderSide(
              color: AppTheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) => _onTap(context, i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.accessibility_new_outlined),
              activeIcon: Icon(Icons.accessibility_new),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.store_outlined),
              activeIcon: Icon(Icons.store),
              label: 'Store',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.design_services_outlined),
              activeIcon: Icon(Icons.design_services),
              label: 'Designer',
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.scan);
      case 1:
        context.go(AppRoutes.store);
      case 2:
        context.go(AppRoutes.order);
      case 3:
        context.go(AppRoutes.designer);
    }
  }
}
