# FitCraft Project Memory

_Last updated: 2026-03-31_

This file is the durable project memory for FitCraft. It replaces the old handoff/history notes and should be kept updated as the project evolves.

## Project Identity

**FitCraft** is a Flutter mobile app for AI-powered virtual try-on and 3D/body-measurement scanning.

### Current product direction
- Android-first
- Bangladesh market
- Pricing in BDT
- Core value proposition:
  - body measurement extraction from photos
  - AI virtual try-on
  - downstream tailoring / designer / order flows

## Current Status

### Phase 1 — Body Scan Foundation
**Done**

Implemented and working at project level:
- camera capture flow
- front/side photo capture UX
- Google ML Kit pose detection integration
- body measurement extraction pipeline
- measurement preview UI

### Phase 2 — AI Virtual Try-On
**Done**

Implemented and reported working end-to-end:
- OOTDiffusion virtual try-on flow
- Replicate API integration

### Phase 3+
Future work should build on the existing architecture rather than re-scaffolding the app.

## Confirmed Tech Stack

### App
- Flutter
- Riverpod
- go_router
- Dio
- Hive / Hive Flutter
- Google Fonts

### Body scan / vision
- `google_mlkit_pose_detection`

### AI try-on
- Replicate API
- OOTDiffusion

### Auth / storage / backend
- Firebase Auth
- Firebase Storage
- Supabase (Postgres)
- FastAPI backend on Railway.app

### Payments / market context
- bKash
- Nagad
- cards
- Bangladesh-first assumptions

## Architecture Direction

The project follows a feature-first structure with separation across:
- `presentation`
- `state`
- `domain`
- shared `core`
- shared app shell/router under `app`

Important conventions:
- use existing patterns before introducing new ones
- prefer small, local refactors over broad rewrites
- keep UI, business logic, and data concerns separate
- avoid hardcoded strings/config where shared constants/helpers make sense

## Project-Local Agent Rules

The canonical working rules live in:
- `.skills/project-operating-rules.md`

This should be read first for coding tasks.

Supporting project-local guidance also exists in `.skills/`.

## Important Technical History

### Earlier historical notes that are now outdated
Older notes described:
- Phase 1 scaffold as complete
- body scan as in progress
- Firebase/Supabase pieces as partially deferred

Those notes are no longer sufficient as the canonical state because the project has moved beyond that stage.

### Freezed/codegen issue that did happen
A real issue previously occurred in `body_measurements.dart` due to incorrect Freezed model structure and stale generation state.

What mattered:
- manual getter-style patterns caused generated-code mismatch problems
- the fix required correcting the model shape and regenerating code

This is a useful caution for future model work:
- avoid manual getter overrides in Freezed data classes unless the pattern is explicitly correct
- regenerate code cleanly after model changes

## Recent Refactor Memory (2026-03-31)

### Project guidance / working rules
- Created `.skills/project-operating-rules.md`
- Updated `.skills/README.md` so project-operating-rules loads first for FitCraft coding work

### Startup / infrastructure cleanup
- Created `lib/app/bootstrap.dart`
- Reduced `main.dart` responsibility by moving platform/service initialization into bootstrap
- Cleaned `lib/core/services/dio_client.dart`

### Scan feature cleanup
- Fixed `body_measurements.dart` Freezed declaration and regenerated code
- Added/supporting scan files:
  - `body_scan_constants.dart`
  - `body_scan_error_mapper.dart`
  - `body_scan_geometry.dart`
  - `body_scan_landmarks.dart`
  - `scan_feedback.dart`
  - `camera_widgets.dart`
  - `measurement_cards.dart`
- Refactored:
  - `body_scan_service.dart`
  - `camera_screen.dart`
  - `measurements_preview_screen.dart`

### Auth cleanup
- Added/supporting auth files:
  - `auth_strings.dart`
  - `auth_action_state.dart`
  - `auth_form_notifier.dart`
  - `auth_feedback.dart`
  - `auth_validation.dart`
  - `password_strength.dart`
  - `auth_widgets.dart`
- Fixed risky Freezed pattern in `user_model.dart`
- Refactored:
  - `login_screen.dart`
  - `signup_screen.dart`
  - `forgot_password_screen.dart`

### Splash cleanup
- Added:
  - `splash_strings.dart`
  - `splash_navigation_provider.dart`
- Refactored splash toward provider-driven timing

### Validation state
After refactor passes, `flutter analyze` was clean.

## Current Cleanup / Audit Snapshot

At the latest audit point, the remaining larger non-generated files still worth attention were:
- `features/auth/domain/auth_repository.dart`
- `features/auth/presentation/login_screen.dart`
- `features/auth/presentation/signup_screen.dart`
- `features/auth/presentation/forgot_password_screen.dart`
- `features/scan/presentation/camera_screen.dart`

This does **not** necessarily mean they are broken; it means they remain likely candidates for further splitting or cleanup under the project rules.

## Operational Notes for Future Work

Before any FitCraft task:
1. inspect existing structure
2. list files to touch
3. flag assumptions explicitly
4. follow existing project patterns unless deviation is justified first

## What This File Replaces

This file supersedes:
- `handoff_summary.md`
- `history.md`

Those files were useful snapshots, but this file should now be treated as the canonical project memory.
