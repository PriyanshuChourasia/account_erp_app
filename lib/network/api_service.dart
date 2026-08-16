import 'package:dio/dio.dart';

import '../core/app_exception.dart';

/// Raw HTTP layer. No parsing, no state — just network calls returning the
/// decoded response body. Envelope parsing happens in repositories.
class ApiService {
  ApiService(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _request(() => _dio.get<dynamic>(path, queryParameters: queryParameters));

  Future<Map<String, dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) => _request(
    () =>
        _dio.post<dynamic>(path, data: data, queryParameters: queryParameters),
  );

  Future<Map<String, dynamic>> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) => _request(
    () => _dio.put<dynamic>(path, data: data, queryParameters: queryParameters),
  );

  Future<Map<String, dynamic>> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) => _request(
    () => _dio.delete<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
    ),
  );

  Future<Map<String, dynamic>> _request(
    Future<Response<dynamic>> Function() call,
  ) async {
    try {
      final response = await call();
      final body = response.data;
      if (body is Map<String, dynamic>) return body;
      if (body == null) return const <String, dynamic>{};
      // This org's backend always wraps responses in the envelope;
      // anything else is an unexpected contract violation.
      throw const AppException('Unexpected response format from the server.');
    } on DioException catch (error) {
      // The error interceptor attaches a normalized AppException when possible.
      if (error.error is AppException) throw error.error as AppException;
      throw AppException.fromDioException(error);
    }
  }
}
