# FitCraft — Phase 1 Handoff Summary

**Date:** March 14, 2026
**Status:** Phase 1 (Project Scaffold) Completed. Ready for Phase 2 (Auth) & Phase 3 (Body Scan).

## What Was Built
We successfully built the **Phase 1: Flutter Project Scaffold**. This provides a clean, compilable Flutter application with the complete target folder structure, state management, and declarative routing ready for feature development.

## Files Created (14 Core Dart Files)

### 1. App Entry & Routing
- `lib/main.dart`: App entry point. Configured with Riverpod `ProviderScope`, system UI overlays (portrait lock), Hive storage initialization, and Dio HTTP client initialization.
- `lib/app/app.dart`: The root `FitCraftApp` using `MaterialApp.router` with the custom dark theme.
- `lib/app/router.dart`: `GoRouter` configuration. Uses `ShellRoute` for a persistent bottom navigation bar across main tabs. All routes are strictly defined as constants in `AppRoutes`.
- `lib/app/home_shell.dart`: The bottom navigation UI shell with 4 tabs (Scan, Store, Orders, Designer).

### 2. Core Infrastructure Layer
- `lib/core/utils/constants.dart`: Centralized app config (API URLs, Bucket names, Hive boxes, Timeouts). No hardcoded strings elsewhere.
- `lib/core/utils/theme.dart`: Premium dark theme featuring the `Outfit` font, custom gradients, and Material 3 design tokens.
- `lib/core/services/dio_client.dart`: Singleton HTTP client with an interceptor to auto-inject auth tokens, and a logging interceptor for debugging.
- `lib/core/services/hive_service.dart`: Key-value local storage setup with predefined boxes for user, settings, and measurements.
- `lib/core/services/api_service.dart`: Typed REST wrappers (GET, POST, PUT, DELETE, UPLOAD) over the `DioClient`.

### 3. Feature Placeholders (`features/<name>/presentation/`)
Empty folder structures (`presentation`, `state`, `domain`) created for all 5 features. Basic placeholder `ConsumerWidget` screens created for routing verification:
- `scan_screen.dart`
- `avatar_screen.dart`
- `store_screen.dart`
- `order_screen.dart`
- `designer_screen.dart`

## Key Dependencies Installed
`flutter_riverpod`, `riverpod_annotation`, `go_router`, `dio`, `hive`/`hive_flutter`, `google_fonts`, `freezed_annotation ^3.0.0`, `json_annotation`, `cached_network_image`, `image_picker`.

*(Code generators installed: `build_runner`, `freezed ^3.0.0`, `json_serializable`, `riverpod_generator`, `riverpod_lint`)*

## Known Limitations & Next Steps

1. **Firebase Configuration Required**:
   `firebase_core`, `firebase_auth`, and `firebase_storage` dependencies were held back for now. In the next session, run `flutterfire configure` to generate the native Firebase files before adding these dependencies back to `pubspec.yaml`.
2. **Supabase Re-Integration**:
   Supabase is linked but the `supabase_flutter` package needs to be re-added when real API calls begin.
3. **ML Kit Android Requirement**:
   For the body scanning feature (Phase 3), the Android `minSdk` must explicitly remain at `21` in `android/app/build.gradle.kts`. When testing the camera and ML Kit pose detection, a **physical Android device** will be required (the emulator camera is inadequate for pose landmarks).
4. **Code Generation**:
   `freezed` models and `riverpod` providers will require running `dart run build_runner build -d` when business logic is implemented.

## Verification
`flutter analyze` runs clean with **0 issues**. Project builds successfully.
