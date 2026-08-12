import 'package:dio/dio.dart';

import '../../core/app_exception.dart';

/// Converts low-level [DioException]s into [AppException]s.
///
/// The normalized exception is attached to the error via `copyWith`, and
/// [ApiService] extracts it so repositories only ever deal with
/// [AppException]. Also logs the failure for observability.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appException = err.error is AppException
        ? err.error as AppException
        : AppException.fromDioException(err);
    handler.next(err.copyWith(error: appException));
  }
}
