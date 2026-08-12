import 'package:dio/dio.dart';

/// Application-level exception thrown by repositories and interceptors.
///
/// Every failure surfaced to the UI is an [AppException] — never a raw
/// [DioException] or a bare error string. Screens catch this type and render
/// it through the shared error handler (`core/handlers/error_handler.dart`).
class AppException implements Exception {
  const AppException(this.message, {this.code, this.statusCode});

  /// Human-readable message that is safe to show to the user.
  final String message;

  /// Business error code returned inside the response envelope (e.g. 1001).
  final int? code;

  /// HTTP status code, when the failure came from an actual response.
  final int? statusCode;

  /// Normalizes a low-level [DioException] into an [AppException].
  factory AppException.fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const AppException('Connection timed out. Please try again.');
      case DioExceptionType.connectionError:
        return const AppException(
          'Unable to reach the server. Check your connection and try again.',
        );
      case DioExceptionType.badCertificate:
        return const AppException('Secure connection could not be verified.');
      case DioExceptionType.cancel:
        return const AppException('Request was cancelled.');
      case DioExceptionType.badResponse:
        return AppException(
          _messageFromResponse(error.response),
          code: _codeFromResponse(error.response),
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.unknown:
        return AppException(
          error.message ?? 'Something went wrong. Please try again.',
        );
    }
  }

  static String _messageFromResponse(Response<dynamic>? response) {
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
      final error = data['error'];
      if (error is String && error.isNotEmpty) return error;
      if (error is Map<String, dynamic>) {
        final errorMessage = error['message'];
        if (errorMessage is String && errorMessage.isNotEmpty) {
          return errorMessage;
        }
      }
    }
    return 'Server error (${response?.statusCode ?? 'unknown'}). Please try again.';
  }

  static int? _codeFromResponse(Response<dynamic>? response) {
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      final code = data['code'];
      if (code is int) return code;
      return int.tryParse('$code');
    }
    return null;
  }

  @override
  String toString() =>
      'AppException(message: $message, code: $code, statusCode: $statusCode)';
}
