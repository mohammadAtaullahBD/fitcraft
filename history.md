# FitCraft — Project History and Current Status

**Target:** Provide context for switching development environments (PCs).

## 1. Project Scaffold (Phase 1) - Completed
The foundational structure of the FitCraft Flutter application is set up and functional:
- **Routing:** Configured using `go_router` with a persistent bottom navigation shell (`home_shell.dart`) and predefined routes (`AppRoutes`).
- **Core Architecture:**
  - Premium Dark Theme (`core/utils/theme.dart`).
  - Centralized constants for API URLs, Hive boxes, etc. (`core/utils/constants.dart`).
  - Dio HTTP Client with interceptors (`core/services/dio_client.dart`).
  - Hive for local storage (`core/services/hive_service.dart`).
  - Feature-first folder structure (auth, avatar, designer, order, scan, splash, store).
- **Dependencies:** Riverpod, Freezed, GoRouter, Dio, Hive, Google Fonts, Image Picker, etc., are installed.

## 2. Body Scanning Feature (Phase 3) - In Progress
Recently, work has been focused on building out the Body Scan feature.

### Implemented Components:
- **Presentation Layer:**
  - `camera_screen.dart`: UI for capturing front and side profile photos.
  - `measurements_preview_screen.dart`: UI to preview extracted measurements.
  - `scan_screen.dart`: Main entry screen for the scan flow.
- **Domain Layer:**
  - `body_scan_service.dart`: Logic for handling Google ML Kit Pose Detection and calculating body measurements.
  - `body_measurements.dart`: Data model representing the extracted measurements.
- **State Layer:**
  - `body_scan_notifier.dart`: State management for the scanning flow.

## 3. Current Issue & State
While setting up the `BodyMeasurements` class (using `@freezed`), an issue occurred with the generated code.

**The Problem:**
Initially, `body_measurements.dart` had manually written `get` overrides (e.g., `double get estimatedHeight => throw UnimplementedError();`) below the factory constructor. 

This violates Freezed conventions and caused analyzer errors because Freezed auto-generates these getters, and adding them manually without a private constructor (`MyClass._()`) leads to build runner failures.

**Actions Taken:**
- We stripped the manual getters from `body_measurements.dart`. Code now correctly looks like this:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'body_measurements.freezed.dart';

@freezed
class BodyMeasurements with _$BodyMeasurements {
  const factory BodyMeasurements({
    required double shoulderWidth,
    required double hipWidth,
    required double torsoLength,
    required double estimatedHeight,
  }) = _BodyMeasurements;
}
```
- We ran `dart run build_runner build --delete-conflicting-outputs` to regenerate the `body_measurements.freezed.dart` file.

**Current Status:**
The `build_runner` process was interrupted or failed on the last run, so the generated files might be stale or missing.

## 4. Next Steps on the New PC
When you switch to your new PC, run the following commands to get the environment ready and resolve the lingering issue:

1. `flutter pub get` (to restore dependencies).
2. `dart run build_runner clean` (to clean up the old build cache).
3. `dart run build_runner build --delete-conflicting-outputs` (to properly generate `.freezed.dart` and `.g.dart` files).

This should resolve the analyzer errors in `body_measurements.dart` and allow you to continue testing the camera and ML Kit integration. Remember, testing the camera and ML Kit requires a **physical Android device**.
