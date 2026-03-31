import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fitcraft/core/services/dio_client.dart';
import 'package:fitcraft/core/services/hive_service.dart';
import 'package:fitcraft/core/utils/constants.dart';
import 'package:fitcraft/firebase_options.dart';

/// Applies global platform UI rules needed before the app starts.
Future<void> configurePlatformUi() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
}

/// Initializes external services and local infrastructure for the app.
Future<void> initializeAppServices() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  await HiveService.instance.init();
  DioClient.instance.init();
}
