import 'package:flutter/foundation.dart';

import '../../../core/app_exception.dart';
import '../models/login_request_model.dart';
import '../models/user_model.dart';
import '../repository/auth_repository.dart';

/// Holds all auth UI state. Screens only ever interact with this class —
/// never with the repository or service directly.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repository);

  final AuthRepository _repository;

  bool _isCheckingSession = true;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;
  UserModel? _user;

  bool get isCheckingSession => _isCheckingSession;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;
  UserModel? get user => _user;

  /// Restores the session on app start (called by [AuthGate]).
  Future<void> checkAuthStatus() async {
    _isCheckingSession = true;
    notifyListeners();
    try {
      if (!await _repository.hasStoredToken()) {
        _user = null;
        _isAuthenticated = false;
        return;
      }
      _user = await _repository.fetchCurrentUser();
      _isAuthenticated = _user != null;
    } on AppException {
      // Keep the user signed in locally even if the profile fetch fails;
      // the next authenticated call will surface a proper error.
      _isAuthenticated = await _repository.hasStoredToken();
    } finally {
      _isCheckingSession = false;
      notifyListeners();
    }
  }

  /// Attempts login. Returns true on success; on failure sets [error] and
  /// returns false so the screen can surface a message.
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final session = await _repository.login(
        LoginRequestModel(username: username, password: password),
      );
      _user = session.user;
      _isAuthenticated = true;
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
  }
}
