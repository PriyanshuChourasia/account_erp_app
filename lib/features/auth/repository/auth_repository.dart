import 'dart:convert';

import '../../../config/token_storage.dart';
import '../../../core/app_exception.dart';
import '../../../data/models/response_model_wrapper.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/register_request_model.dart';
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

  /// Creates a new account. Throws [AppException] when the backend rejects
  /// the registration. If the response includes a session token (some
  /// backends log the user in immediately on register), it's stored and the
  /// profile is fetched and persisted just like after [login].
  Future<void> register(RegisterRequestModel request) async {
    final json = await _authService.register(request);
    final wrapper = ResponseModelWrapper<LoginResponseModel>.fromJson(
      json,
      fromJson: LoginResponseModel.fromJson,
    );
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Registration failed. Please try again.',
        code: wrapper.code,
      );
    }
    final token = wrapper.data?.result?.token;
    if (token != null && token.isNotEmpty) {
      await _tokenStorage.setToken(token);
      try {
        await fetchCurrentUser();
      } on AppException {
        // Best-effort: registration still succeeded either way.
      }
    }
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

  Future<void> logout() async {
    try {
      await _authService.logout();
    } on AppException {
      // Best-effort: clear the local session regardless of server response.
    } finally {
      await _tokenStorage.clearToken();
      await _tokenStorage.clearUserJson();
    }
  }
}
