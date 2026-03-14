---
name: supabase-firebase-split
description: "Use this skill whenever FitCraft stores or retrieves data. Triggers: any database query, file upload, auth operation, or mention of Firebase, Supabase, Firestore, or Storage. Clarifies the strict split: Firebase = Auth + Storage only, Supabase = all relational data."
---

# FitCraft — Firebase & Supabase Data Architecture

## The Rule: Strict Responsibility Split

| System | Responsibility | Never Use For |
|--------|---------------|---------------|
| **Firebase Auth** | User sign-in, sign-up, Google OAuth, session tokens | Storing user profile data |
| **Firebase Storage** | Garment images, avatar photos, try-on results | Metadata, queries, relationships |
| **Supabase (Postgres)** | Users, designs, orders, earnings, measurements | Binary files, auth sessions |

**Do not use Firestore. FitCraft does not use Firestore at all.**

---

## Supabase Schema (Create These Tables)

```sql
-- Run in Supabase SQL Editor

-- Users (mirrors Firebase Auth UID)
CREATE TABLE users (
  id            UUID PRIMARY KEY,          -- same as Firebase Auth UID
  email         TEXT NOT NULL UNIQUE,
  name          TEXT NOT NULL,
  role          TEXT NOT NULL DEFAULT 'customer'  -- 'customer' | 'designer'
                CHECK (role IN ('customer', 'designer')),
  avatar_url    TEXT,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- Designs uploaded by designers
CREATE TABLE designs (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  designer_id   UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name          TEXT NOT NULL,
  image_url     TEXT NOT NULL,             -- Firebase Storage URL
  price_bdt     INTEGER NOT NULL,          -- price in Bangladeshi Taka
  category      TEXT NOT NULL             -- 'traditional' | 'western' | 'casual' | 'formal'
                CHECK (category IN ('traditional', 'western', 'casual', 'formal')),
  tags          TEXT[] DEFAULT '{}',
  is_active     BOOLEAN DEFAULT TRUE,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- Orders placed by customers
CREATE TABLE orders (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id       UUID NOT NULL REFERENCES users(id),
  design_id         UUID NOT NULL REFERENCES designs(id),
  measurements_json JSONB NOT NULL,        -- BodyMeasurements serialized
  tailor_id         UUID REFERENCES users(id),
  status            TEXT NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending', 'confirmed', 'in_progress', 'completed', 'cancelled')),
  total_bdt         INTEGER NOT NULL,
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

-- Designer earnings per order
CREATE TABLE earnings (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  designer_id   UUID NOT NULL REFERENCES users(id),
  order_id      UUID NOT NULL REFERENCES orders(id),
  amount_bdt    INTEGER NOT NULL,          -- designer's cut (e.g. 20% of order)
  paid_out      BOOLEAN DEFAULT FALSE,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for common queries
CREATE INDEX idx_designs_designer ON designs(designer_id);
CREATE INDEX idx_designs_category ON designs(category);
CREATE INDEX idx_orders_customer  ON orders(customer_id);
CREATE INDEX idx_orders_status    ON orders(status);
```

---

## SupabaseService Implementation

```dart
// core/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'supabase_service.g.dart';

@riverpod
SupabaseService supabaseService(SupabaseServiceRef ref) => SupabaseService();

class SupabaseService {
  SupabaseClient get _client => Supabase.instance.client;

  // ── Users ──────────────────────────────────────────────────

  Future<void> upsertUser({
    required String id,       // Firebase Auth UID
    required String email,
    required String name,
    required String role,
  }) async {
    await _client.from('users').upsert({
      'id': id, 'email': email, 'name': name, 'role': role,
    });
  }

  Future<Map<String, dynamic>?> getUser(String id) async {
    return await _client.from('users').select().eq('id', id).maybeSingle();
  }

  // ── Designs ────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getDesigns({String? category}) async {
    var query = _client
        .from('designs')
        .select('*, users!designer_id(name)')
        .eq('is_active', true)
        .order('created_at', ascending: false);

    if (category != null && category != 'all') {
      query = query.eq('category', category);
    }
    return await query;
  }

  Future<void> uploadDesign({
    required String designerId,
    required String name,
    required String imageUrl,
    required int priceBdt,
    required String category,
    List<String> tags = const [],
  }) async {
    await _client.from('designs').insert({
      'designer_id': designerId,
      'name': name,
      'image_url': imageUrl,
      'price_bdt': priceBdt,
      'category': category,
      'tags': tags,
    });
  }

  // ── Orders ─────────────────────────────────────────────────

  Future<String> createOrder({
    required String customerId,
    required String designId,
    required Map<String, dynamic> measurementsJson,
    required int totalBdt,
  }) async {
    final response = await _client.from('orders').insert({
      'customer_id': customerId,
      'design_id': designId,
      'measurements_json': measurementsJson,
      'total_bdt': totalBdt,
    }).select('id').single();

    return response['id'] as String;
  }

  // ── Designer Earnings ──────────────────────────────────────

  Future<int> getDesignerEarnings(String designerId) async {
    final response = await _client
        .from('earnings')
        .select('amount_bdt')
        .eq('designer_id', designerId)
        .eq('paid_out', false);

    return (response as List)
        .fold(0, (sum, row) => sum + (row['amount_bdt'] as int));
  }
}
```

---

## Firebase Auth + Supabase Sync Pattern

When a user registers, create records in both systems:

```dart
// core/services/auth_service.dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SupabaseService _supabase;

  AuthService(this._supabase);

  Future<UserCredential> register({
    required String email,
    required String password,
    required String name,
    required String role,   // 'customer' | 'designer'
  }) async {
    // 1. Create Firebase Auth user
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email, password: password,
    );

    // 2. Sync to Supabase users table
    await _supabase.upsertUser(
      id: cred.user!.uid,   // Firebase UID as Supabase PK
      email: email,
      name: name,
      role: role,
    );

    return cred;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String? get currentUserId => _auth.currentUser?.uid;
}
```

---

## Firebase Storage Upload Pattern

```dart
// core/services/storage_service.dart
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload garment image. Returns public download URL.
  Future<String> uploadGarmentImage({
    required String designerId,
    required String filename,
    required Uint8List imageBytes,
  }) async {
    final ref = _storage.ref('garments/$designerId/$filename');
    final task = await ref.putData(
      imageBytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await task.ref.getDownloadURL();
  }

  /// Upload avatar/body scan photo.
  Future<String> uploadAvatarPhoto({
    required String userId,
    required Uint8List imageBytes,
  }) async {
    final ref = _storage.ref('avatars/$userId/scan_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final task = await ref.putData(imageBytes,
      SettableMetadata(contentType: 'image/jpeg'));
    return await task.ref.getDownloadURL();
  }
}
```

---

## Initialization in main.dart

```dart
// main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // Firebase init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Supabase init
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const ProviderScope(child: FitCraftApp()));
}
```

---

## .env Variables Required

```
SUPABASE_URL=https://xxxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Firebase config goes in `android/app/google-services.json` (not in .env).

---

## Quick Reference: Where Does Each Thing Live?

| Data | System | Table / Path |
|------|--------|-------------|
| User login session | Firebase Auth | (managed by SDK) |
| User profile (name, role) | Supabase | `users` table |
| Garment image file | Firebase Storage | `garments/{designerId}/{filename}` |
| Garment metadata | Supabase | `designs` table |
| Body scan photo | Firebase Storage | `avatars/{userId}/scan_*.jpg` |
| Body measurements | Supabase | `orders.measurements_json` |
| Order record | Supabase | `orders` table |
| Designer earnings | Supabase | `earnings` table |
| Wishlist (offline) | Hive (local) | `wishlist` box |
| Try-on result image | Firebase Storage | (cached URL stored in Hive) |
