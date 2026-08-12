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
    return session;
  }

  /// Creates a new account. Throws [AppException] when the backend rejects
  /// the registration; on success the user signs in through the login flow.
  /// The envelope carries no meaningful `result` payload, so no converter is
  /// applied — only the `success` flag matters here.
  Future<void> register(RegisterRequestModel request) async {
    final json = await _authService.register(request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Registration failed. Please try again.',
        code: wrapper.code,
      );
    }
  }

  /// Returns the current user, or null when no session is stored locally.
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
    return wrapper.data?.result;
  }

  Future<bool> hasStoredToken() => _tokenStorage.hasToken();

  Future<void> logout() async {
    try {
      await _authService.logout();
    } on AppException {
      // Best-effort: clear the local session regardless of server response.
    } finally {
      await _tokenStorage.clearToken();
    }
  }
}
