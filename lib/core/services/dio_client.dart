import 'package:dio/dio.dart';
import 'package:fitcraft/core/utils/constants.dart';
import 'package:flutter/foundation.dart';

/// Singleton Dio HTTP client with auth-token & error-logging interceptors.
class DioClient {
  DioClient._internal();
  static final DioClient _instance = DioClient._internal();
  static DioClient get instance => _instance;

  late final Dio dio;
  String? _authToken;

  /// Initialise once at app startup.
  void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Auth interceptor — injects bearer token if available.
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          _logError(error);
          return handler.next(error);
        },
      ),
    );

    // Logging interceptor (debug only).
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
        ),
      );
    }
  }

  /// Update the auth token (call after login / token refresh).
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Centralised error logging.
  void _logError(DioException error) {
    debugPrint('┌── DIO ERROR ──────────────────────────────');
    debugPrint('│ URL:    ${error.requestOptions.uri}');
    debugPrint('│ Method: ${error.requestOptions.method}');
    debugPrint('│ Status: ${error.response?.statusCode}');
    debugPrint('│ Message: ${error.message}');
    debugPrint('└───────────────────────────────────────────');
  }
}
