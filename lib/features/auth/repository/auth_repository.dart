import 'dart:convert';

import '../../../config/token_storage.dart';
import '../../../core/app_exception.dart';
import '../../../data/models/response_model_wrapper.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Orchestrates auth data: calls [AuthService], unwraps the
/// [ResponseModelWrapper] envelope and throws [AppException] on failure.
class AuthRepository {
  AuthRepository(this._authService, this._tokenStorage);

  final AuthService _authService;
  final TokenStorage _tokenStorage;

  Future<LoginResponseModel> login(LoginRequestModel request) async {
    final json = await _authService.login(request);
    final wrapper = ResponseModelWrapper<LoginResponseModel>.fromJson(
      json,
      fromJson: LoginResponseModel.fromJson,
    );
    final session = wrapper.data?.result;
    if (!wrapper.success || session == null) {
      throw AppException(
        wrapper.message ?? 'Login failed. Please try again.',
        code: wrapper.code,
      );
    }
    await _tokenStorage.setToken(session.token);
    // Fetch the authoritative profile (username/contactNo aren't guaranteed
    // to be present on the login response) and persist it locally.
    try {
      final profile = await fetchCurrentUser();
      if (profile != null) {
        return LoginResponseModel(token: session.token, user: profile);
      }
    } on AppException {
      // Login still succeeded even if the follow-up profile fetch failed.
    }
    return session;
  }

  /// Returns the current user, or null when no session is stored locally.
  /// Persists the fetched profile locally on success.
  Future<UserModel?> fetchCurrentUser() async {
    if (!await _tokenStorage.hasToken()) return null;
    final json = await _authService.fetchProfile();
    final wrapper = ResponseModelWrapper<UserModel>.fromJson(
      json,
      fromJson: UserModel.fromJson,
    );
    if (!wrapper.success || wrapper.data?.result == null) {
      throw AppException(
        wrapper.message ?? 'Could not load your profile.',
        code: wrapper.code,
      );
    }
    final user = wrapper.data!.result!;
    await _tokenStorage.setUserJson(jsonEncode(user.toJson()));
    return user;
  }

  /// Returns the last profile persisted locally, or null if none is stored
  /// or it can't be parsed.
  Future<UserModel?> getStoredUser() async {
    final json = await _tokenStorage.getUserJson();
    if (json == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<bool> hasStoredToken() => _tokenStorage.hasToken();

  /// Clears the locally stored session. Purely local — there is no backend
  /// logout endpoint to call yet.
  Future<void> logout() async {
    await _tokenStorage.clearToken();
    await _tokenStorage.clearUserJson();
  }
}
