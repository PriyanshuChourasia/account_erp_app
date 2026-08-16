import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

/// Builds the shared [Dio] instance with base URL, timeouts and interceptors.
class DioClient {
  DioClient({
    AuthInterceptor? authInterceptor,
    ErrorInterceptor? errorInterceptor,
  }) : _authInterceptor = authInterceptor ?? AuthInterceptor(),
       _errorInterceptor = errorInterceptor ?? ErrorInterceptor();

  final AuthInterceptor _authInterceptor;
  final ErrorInterceptor _errorInterceptor;

  late final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: ApiConfig.connectTimeout,
            receiveTimeout: ApiConfig.receiveTimeout,
            responseType: ResponseType.json,
            headers: const {'Content-Type': 'application/json'},
          ),
        )
        ..interceptors.addAll([
          _authInterceptor,
          _errorInterceptor,
          if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true),
        ]);
}
