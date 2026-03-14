// Core constants — all API base URLs and app-wide configuration.
// Switch between dev and prod by changing the active profile.

class AppConstants {
  AppConstants._();

  // ─── Environment ───────────────────────────────────────────────
  static const bool isProduction = false;

  // ─── API Base URLs ─────────────────────────────────────────────
  static const String devBaseUrl = 'http://10.0.2.2:8000/api/v1';
  static const String prodBaseUrl = 'https://fitcraft-api.railway.app/api/v1';

  static String get baseUrl => isProduction ? prodBaseUrl : devBaseUrl;

  // ─── Replicate (OOTDiffusion) ──────────────────────────────────
  static const String replicateBaseUrl = 'https://api.replicate.com/v1';
  // API token is loaded from environment / secure storage at runtime.

  // ─── Supabase ──────────────────────────────────────────────────
  // These will be populated from environment config.
  static const String supabaseUrl = '';
  static const String supabaseAnonKey = '';

  // ─── Storage Buckets ───────────────────────────────────────────
  static const String scanImagesBucket = 'scan-images';
  static const String tryOnResultsBucket = 'try-on-results';

  // ─── Hive Box Names ────────────────────────────────────────────
  static const String userBox = 'user_box';
  static const String settingsBox = 'settings_box';
  static const String measurementsBox = 'measurements_box';

  // ─── App Info ──────────────────────────────────────────────────
  static const String appName = 'FitCraft';
  static const String appTagline = 'Your Perfect Fit, Crafted by AI';

  // ─── Payment Providers ─────────────────────────────────────────
  static const String bkashBaseUrl = 'https://tokenized.sandbox.bka.sh/v1.2.0-beta';
  static const String nagadBaseUrl = 'https://sandbox.nagad.com.bd/api/v1';

  // ─── Timeouts ──────────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
