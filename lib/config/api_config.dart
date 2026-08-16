import 'dart:io';

/// Central place for API endpoints and connection settings.
///
/// Replace [ApiConfig.baseUrl] with the real backend before going live.
class ApiConfig {
  ApiConfig._();

  // TODO: point this at the real backend.
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8060/api';
    }
    return 'http://127.0.0.1:8060/api';
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ---- Auth endpoints ----
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String profileEndpoint = '/auth/profile';

  // ---- Item endpoints ----
  static const String itemsEndpoint = '/items';
  static String itemEndpoint(String id) => '/items/$id';

  // ---- Stock group endpoints ----
  static const String stockGroupsEndpoint = '/stock-groups';
  static const String stockGroupCreateEndpoint = '/stock-groups/create';
  static String stockGroupEndpoint(int id) => '/stock-groups/$id';

  // ---- Stock category endpoints ----
  static const String stockCategoriesEndpoint = '/stock-categories';
  static const String stockCategoryCreateEndpoint = '/stock-categories/create';
  static String stockCategoryEndpoint(int id) => '/stock-categories/$id';

  // ---- Stock item endpoints ----
  static const String stockItemsEndpoint = '/stock-items';
  static const String stockItemCreateEndpoint = '/stock-items/create';
  static String stockItemEndpoint(int id) => '/stock-items/$id';

  // ---- Unit endpoints ----
  static const String unitCreateEndpoint = '/units/create';
  static String unitEndpoint(int id) => '/units/$id';

  // Endpoints that do not require an Authorization header.
  static const Set<String> publicEndpoints = {loginEndpoint, registerEndpoint};

  // ---- Storage keys ----
  static const String tokenKey = 'auth_token';
}
