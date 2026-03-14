import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitcraft/app/app.dart';
import 'package:fitcraft/core/services/dio_client.dart';
import 'package:fitcraft/core/services/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode (better for body scanning UX).
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // ─── Core service initialisation ──────────────────────────────
  // Firebase — will be initialised in Phase 2 (Auth).
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Hive local storage.
  await HiveService.instance.init();

  // Dio HTTP client.
  DioClient.instance.init();

  // Supabase — already linked by CLI; will be initialised in Phase 2.
  // await Supabase.initialize(url: '...', anonKey: '...');

  runApp(
    const ProviderScope(
      child: FitCraftApp(),
    ),
  );
}
