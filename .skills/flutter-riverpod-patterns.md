---
name: flutter-riverpod-patterns
description: "Use this skill for all Flutter + Riverpod code in the FitCraft project. Triggers: any screen, widget, state class, notifier, or provider being created or modified. Enforces consistent ConsumerWidget, sealed state, freezed, and Dio patterns across all features."
---

# FitCraft — Flutter & Riverpod Patterns

## Architecture Rules (Never Deviate)

| Rule | Detail |
|------|--------|
| Every screen | Must be a `ConsumerWidget` — never `StatelessWidget` or `StatefulWidget` |
| All async ops | Go through Riverpod notifiers — never `setState` or `FutureBuilder` in UI |
| State shape | Sealed class with `loading / success / error` variants using `freezed` |
| HTTP | Always use the shared `Dio` instance with interceptors — never `http` package |
| Strings | No hardcoded strings — use `AppConstants` or `AppStrings` in `core/utils/` |
| Base URLs | Single `AppConstants` file — never inline |

---

## Folder Structure (Enforce Strictly)

```
lib/
├── main.dart
├── app/
│   └── router.dart
├── features/
│   ├── scan/
│   │   ├── presentation/    ← screens + widgets only
│   │   ├── state/           ← Riverpod notifiers
│   │   └── domain/          ← models + services
│   ├── avatar/
│   ├── store/
│   ├── order/
│   └── designer/
└── core/
    ├── services/            ← ApiClient, shared services
    ├── models/              ← shared data models
    └── utils/               ← AppConstants, AppStrings, helpers
```

---

## Sealed State Pattern (Use This for Every Feature)

```dart
// features/scan/state/scan_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../domain/body_measurements.dart';
part 'scan_state.freezed.dart';

@freezed
class ScanState with _$ScanState {
  const factory ScanState.initial()                        = _Initial;
  const factory ScanState.scanning()                       = _Scanning;
  const factory ScanState.success(BodyMeasurements data)   = _Success;
  const factory ScanState.error(String message)            = _Error;
}
```

---

## Notifier Pattern (AsyncNotifier or Notifier)

```dart
// features/scan/state/scan_notifier.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'scan_state.dart';
import '../domain/body_scan_service.dart';
part 'scan_notifier.g.dart';

@riverpod
class ScanNotifier extends _$ScanNotifier {
  @override
  ScanState build() => const ScanState.initial();

  Future<void> scan(XFile photo) async {
    state = const ScanState.scanning();
    try {
      final measurements = await ref.read(bodyScanServiceProvider).scan(photo);
      state = ScanState.success(measurements);
    } catch (e) {
      state = ScanState.error(e.toString());
    }
  }

  void reset() => state = const ScanState.initial();
}
```

---

## ConsumerWidget Screen Pattern

```dart
// features/scan/presentation/measurements_preview_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/scan_notifier.dart';

class MeasurementsPreviewScreen extends ConsumerWidget {
  const MeasurementsPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scanNotifierProvider);

    return Scaffold(
      body: state.when(
        initial: () => const Center(child: Text('Take a photo to begin')),
        scanning: () => const Center(child: CircularProgressIndicator()),
        success: (measurements) => _MeasurementsCard(measurements: measurements),
        error: (msg) => Center(child: Text('Error: $msg')),
      ),
    );
  }
}
```

---

## Freezed Model Pattern

```dart
// features/scan/domain/body_measurements.dart
import 'package:freezed_annotation/freezed_annotation.dart';
part 'body_measurements.freezed.dart';
part 'body_measurements.g.dart';

@freezed
class BodyMeasurements with _$BodyMeasurements {
  const factory BodyMeasurements({
    required double shoulderWidth,   // cm
    required double hipWidth,         // cm
    required double torsoLength,      // cm
    required double estimatedHeight,  // cm
  }) = _BodyMeasurements;

  factory BodyMeasurements.fromJson(Map<String, dynamic> json) =>
      _$BodyMeasurementsFromJson(json);
}
```

---

## Dio Client Pattern (Shared Instance)

```dart
// core/services/api_client.dart
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/app_constants.dart';
part 'api_client.g.dart';

@riverpod
Dio apiClient(ApiClientRef ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));

  // Auth interceptor
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      // Add token from auth state if available
      handler.next(options);
    },
    onError: (error, handler) {
      // Log and forward errors
      debugPrint('API Error: ${error.message}');
      handler.next(error);
    },
  ));

  return dio;
}
```

---

## AppConstants Pattern

```dart
// core/utils/app_constants.dart
class AppConstants {
  AppConstants._();

  // API
  static const String apiBaseUrl    = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://localhost:8000');
  static const String replicateKey  = String.fromEnvironment('REPLICATE_KEY');

  // Routes
  static const String routeHome     = '/';
  static const String routeScan     = '/scan';
  static const String routeStore    = '/store';
  static const String routeTryOn    = '/try-on';
  static const String routeWishlist = '/wishlist';
  static const String routeDesigner = '/designer';

  // Measurements
  static const double pixelToCm = 0.0264583;  // 1px = 0.026cm at 96dpi — calibrate per device
}
```

---

## go_router Setup Pattern

```dart
// app/router.dart
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: AppConstants.routeHome,
    redirect: (context, state) {
      final isAuth = ref.read(authNotifierProvider).maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );
      final goingToLogin = state.matchedLocation == '/login';
      if (!isAuth && !goingToLogin) return '/login';
      if (isAuth && goingToLogin) return AppConstants.routeHome;
      return null;
    },
    routes: [
      // Define all routes here
    ],
  );
}
```

---

## pubspec.yaml Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^13.2.0
  google_mlkit_pose_detection: ^0.10.0
  camera: ^0.10.5
  dio: ^5.4.3
  hive_flutter: ^1.1.0
  firebase_core: ^2.30.1
  firebase_auth: ^4.19.6
  firebase_storage: ^11.7.6
  supabase_flutter: ^2.5.0
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0
  flutter_dotenv: ^5.1.0
  image_picker: ^1.0.7
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0

dev_dependencies:
  build_runner: ^2.4.9
  riverpod_generator: ^2.4.0
  freezed: ^2.5.2
  json_serializable: ^6.8.0
```

---

## Code Generation

After creating any file with `@freezed`, `@riverpod`, or `@JsonSerializable`:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Run this after every new model or notifier. Never commit without running build_runner.

---

## Critical Rules

- **Never** use `StatefulWidget` for screens — always `ConsumerWidget`
- **Never** call services directly from `build()` — use notifiers
- **Never** hardcode strings, URLs, or keys — use `AppConstants`
- **Always** run `build_runner` after adding `@freezed` or `@riverpod`
- **Always** handle all 3 state branches (loading / success / error) in UI
- State notifiers **reset** on screen exit if the data is ephemeral (e.g. scan result)
