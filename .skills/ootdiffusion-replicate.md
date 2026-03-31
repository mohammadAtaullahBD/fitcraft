---
name: ootdiffusion-replicate
description: "Use this skill whenever FitCraft needs to call the OOTDiffusion virtual try-on AI. Triggers: TryOnScreen, ReplicateService, any reference to 'try on', 'garment', 'Replicate API', or OOTDiffusion. Covers the exact model ID, async polling loop, input format, error handling, and cost management."
---

# FitCraft — OOTDiffusion via Replicate API

## Model Details

| Field | Value |
|-------|-------|
| Model ID | `levihsu/ootdiffusion` |
| Replicate URL | `https://api.replicate.com/v1/predictions` |
| Cost | ~$0.01 per image |
| Processing time | 20–40 seconds (async polling required) |
| Input | person image + garment image (both as base64 or public URL) |
| Output | URL to generated try-on image |

---

## How Replicate Async Works (Critical)

Replicate does NOT return the image immediately. The flow is:

```
POST /v1/predictions          → returns prediction ID + status: "starting"
    ↓ poll every 3 seconds
GET /v1/predictions/{id}      → status: "processing"
    ↓ poll again
GET /v1/predictions/{id}      → status: "succeeded" + output URL
```

**Never** assume the first response contains the image. Always poll.

---

## ReplicateService Implementation

```dart
// core/services/replicate_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/app_constants.dart';
import 'api_client.dart';
part 'replicate_service.g.dart';

@riverpod
ReplicateService replicateService(ReplicateServiceRef ref) {
  return ReplicateService(ref.read(apiClientProvider));
}

class ReplicateService {
  final Dio _dio;
  static const String _baseUrl = 'https://api.replicate.com/v1';
  static const String _modelVersion = 'levihsu/ootdiffusion';

  ReplicateService(this._dio);

  /// Sends person + garment images and returns the try-on result image URL.
  /// Accepts image bytes (Uint8List) for both inputs.
  Future<String> tryOn({
    required Uint8List personImageBytes,
    required Uint8List garmentImageBytes,
    String category = 'upper_body', // 'upper_body' | 'lower_body' | 'dresses'
  }) async {
    final String personBase64  = base64Encode(personImageBytes);
    final String garmentBase64 = base64Encode(garmentImageBytes);

    // Step 1: Create prediction
    final createResponse = await _dio.post(
      '$_baseUrl/models/$_modelVersion/predictions',
      options: Options(headers: {
        'Authorization': 'Token ${AppConstants.replicateKey}',
        'Content-Type': 'application/json',
      }),
      data: {
        'input': {
          'vton_img': 'data:image/jpeg;base64,$personBase64',
          'garm_img': 'data:image/jpeg;base64,$garmentBase64',
          'category': category,
          'n_samples': 1,
          'n_steps': 20,
          'image_scale': 2.0,
          'seed': -1,
        }
      },
    );

    final String predictionId = createResponse.data['id'];
    if (predictionId.isEmpty) throw Exception('Replicate: no prediction ID returned');

    // Step 2: Poll until complete
    return _pollUntilComplete(predictionId);
  }

  Future<String> _pollUntilComplete(String predictionId) async {
    const int maxAttempts   = 30;   // 30 × 3s = 90 seconds max wait
    const Duration interval = Duration(seconds: 3);

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      await Future.delayed(interval);

      final pollResponse = await _dio.get(
        '$_baseUrl/predictions/$predictionId',
        options: Options(headers: {
          'Authorization': 'Token ${AppConstants.replicateKey}',
        }),
      );

      final String status = pollResponse.data['status'];
      debugPrint('Replicate poll #$attempt: $status');

      switch (status) {
        case 'succeeded':
          final output = pollResponse.data['output'];
          if (output == null || (output is List && output.isEmpty)) {
            throw Exception('Replicate: succeeded but no output');
          }
          // Output is a list of URLs — return the first
          return output is List ? output[0] as String : output as String;

        case 'failed':
        case 'canceled':
          final error = pollResponse.data['error'] ?? 'Unknown error';
          throw Exception('Replicate prediction $status: $error');

        case 'starting':
        case 'processing':
          continue; // Keep polling
      }
    }

    throw Exception('Replicate: timed out after ${maxAttempts * 3} seconds');
  }
}
```

---

## TryOnNotifier State

```dart
// features/store/state/try_on_notifier.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'try_on_state.dart';
import '../../../core/services/replicate_service.dart';
part 'try_on_notifier.g.dart';

@riverpod
class TryOnNotifier extends _$TryOnNotifier {
  @override
  TryOnState build() => const TryOnState.idle();

  Future<void> tryOn({
    required Uint8List personImageBytes,
    required Uint8List garmentImageBytes,
    String category = 'upper_body',
  }) async {
    state = const TryOnState.loading();
    try {
      final url = await ref.read(replicateServiceProvider).tryOn(
        personImageBytes: personImageBytes,
        garmentImageBytes: garmentImageBytes,
        category: category,
      );
      state = TryOnState.success(url);
    } catch (e) {
      state = TryOnState.error(e.toString());
    }
  }

  void reset() => state = const TryOnState.idle();
}

// State sealed class
@freezed
class TryOnState with _$TryOnState {
  const factory TryOnState.idle()                    = _Idle;
  const factory TryOnState.loading()                 = _Loading;
  const factory TryOnState.success(String imageUrl)  = _Success;
  const factory TryOnState.error(String message)     = _Error;
}
```

---

## TryOnScreen UI Pattern

```dart
// features/store/presentation/try_on_screen.dart
class TryOnScreen extends ConsumerWidget {
  const TryOnScreen({super.key, required this.garment});
  final Garment garment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tryOnNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Virtual Try-On')),
      body: state.when(
        idle: () => _IdleView(garment: garment),
        loading: () => const _LoadingView(),   // Show progress message
        success: (url) => _ResultView(imageUrl: url),
        error: (msg) => _ErrorView(message: msg),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'AI is generating your look...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '(~20–40 seconds)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
```

---

## Image Category Mapping

| Garment Type | category value |
|---|---|
| T-shirt, shirt, jacket, top | `upper_body` |
| Pants, skirts, shorts | `lower_body` |
| Full dress, sari, salwar kameez | `dresses` |

Set category based on the garment's `category` field in the `Garment` model.

---

## Error Handling Reference

| Error | Cause | Fix |
|-------|-------|-----|
| `401 Unauthorized` | Bad API key | Check `REPLICATE_KEY` in `.env` |
| `422 Unprocessable` | Wrong input format | Ensure base64 prefix `data:image/jpeg;base64,` |
| `Timed out` | Model cold start | Increase `maxAttempts` or retry once |
| `succeeded but no output` | Model returned null | Retry — rare OOTDiffusion edge case |

---

## Cost Management

- Each call costs ~$0.01 — log every call in production
- Cache the result URL in Hive locally so user can revisit without re-calling
- In Phase 1 prototype, limit to 5 free try-ons per user (track in Supabase)
- When revenue allows, self-host OOTDiffusion on a GPU server (~$0.001/image)

---

## .env Setup

```
# .env (never commit this file)
REPLICATE_KEY=r8_xxxxxxxxxxxxxxxxxxxx
API_BASE_URL=http://localhost:8000
```

Load with `flutter_dotenv`:
```dart
// main.dart
await dotenv.load(fileName: '.env');
```

Access:
```dart
// core/utils/app_constants.dart
static String get replicateKey => dotenv.env['REPLICATE_KEY'] ?? '';
```
