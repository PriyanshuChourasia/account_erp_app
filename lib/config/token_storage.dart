import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

/// Persists the auth token (and other session data) locally.
///
/// An optional [SharedPreferences] instance can be injected for testing;
/// otherwise it is resolved lazily from the platform.
class TokenStorage {
  TokenStorage({SharedPreferences? preferences}) : _preferences = preferences;

  SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async =>
      _preferences ??= await SharedPreferences.getInstance();

  Future<String?> getToken() async =>
      (await _prefs).getString(ApiConfig.tokenKey);

  Future<void> setToken(String token) async {
    await (await _prefs).setString(ApiConfig.tokenKey, token);
  }

  Future<void> clearToken() async {
    await (await _prefs).remove(ApiConfig.tokenKey);
  }

  Future<bool> hasToken() async => (await getToken())?.isNotEmpty ?? false;

  /// Persists the signed-in user's profile as a raw JSON string. Kept
  /// feature-agnostic here — encoding/decoding into [UserModel] is the
  /// repository's job.
  Future<String?> getUserJson() async =>
      (await _prefs).getString(ApiConfig.userKey);

  Future<void> setUserJson(String json) async {
    await (await _prefs).setString(ApiConfig.userKey, json);
  }

  Future<void> clearUserJson() async {
    await (await _prefs).remove(ApiConfig.userKey);
  }
}
