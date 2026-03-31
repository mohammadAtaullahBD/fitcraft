import 'package:dio/dio.dart';
import 'package:fitcraft/core/utils/constants.dart';
import 'package:flutter/foundation.dart';

/// Singleton Dio HTTP client with auth-token and error-logging interceptors.
class DioClient {
  DioClient._internal();
  static final DioClient _instance = DioClient._internal();
  static DioClient get instance => _instance;

  late final Dio dio;
  bool _isInitialized = false;
  String? _authToken;

  /// Initializes Dio once at app startup.
  void init() {
    if (_isInitialized) return;

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

    dio.interceptors.add(_buildAuthAndErrorInterceptor());

    if (kDebugMode) {
      dio.interceptors.add(_buildDebugLogInterceptor());
    }

    _isInitialized = true;
  }

  /// Updates the auth token used for outgoing requests.
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Builds the interceptor responsible for auth headers and error logging.
  InterceptorsWrapper _buildAuthAndErrorInterceptor() {
    return InterceptorsWrapper(
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
    );
  }

  /// Builds verbose Dio logging for debug builds.
  LogInterceptor _buildDebugLogInterceptor() {
    return LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    );
  }

  /// Prints a consistent error summary for failed HTTP requests.
  void _logError(DioException error) {
    debugPrint('┌── DIO ERROR ──────────────────────────────');
    debugPrint('│ URL:    ${error.requestOptions.uri}');
    debugPrint('│ Method: ${error.requestOptions.method}');
    debugPrint('│ Status: ${error.response?.statusCode}');
    debugPrint('│ Message: ${error.message}');
    debugPrint('└───────────────────────────────────────────');
  }
}
