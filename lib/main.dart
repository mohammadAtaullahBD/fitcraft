import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitcraft/app/app.dart';
import 'package:fitcraft/app/bootstrap.dart';

/// Boots the FitCraft application and its required services.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configurePlatformUi();
  await initializeAppServices();

  runApp(
    const ProviderScope(
      child: FitCraftApp(),
    ),
  );
}
