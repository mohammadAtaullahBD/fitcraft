import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fitcraft/firebase_options.dart';
import 'package:fitcraft/app/app.dart';
import 'package:fitcraft/core/utils/constants.dart';
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

  // Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Supabase.
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Hive local storage.
  await HiveService.instance.init();

  // Dio HTTP client.
  DioClient.instance.init();

  runApp(
    const ProviderScope(
      child: FitCraftApp(),
    ),
  );
}
