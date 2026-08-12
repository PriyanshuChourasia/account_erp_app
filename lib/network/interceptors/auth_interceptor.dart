import 'package:dio/dio.dart';

import '../../config/api_config.dart';
import '../../config/token_storage.dart';
import '../service_locator.dart';

/// Attaches the bearer token to outgoing requests.
///
/// The token is resolved lazily through the service locator so this
/// interceptor can be built before [TokenStorage] has finished loading.
class AuthInterceptor extends Interceptor {
  TokenStorage? _tokenStorage;

  TokenStorage get _storage => _tokenStorage ??= globalService<TokenStorage>();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip public endpoints (e.g. login) — a stale token must not be sent there.
    if (ApiConfig.publicEndpoints.contains(options.path)) {
      handler.next(options);
      return;
    }

    final token = await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
