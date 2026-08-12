import 'package:flutter/foundation.dart';

import '../../../core/app_exception.dart';
import '../models/register_request_model.dart';
import '../repository/auth_repository.dart';

/// Holds all registration UI state.
///
/// Provided locally at the [RegisterScreen] (not global) since nothing
/// outside the screen needs it.
class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel(this._repository);

  final AuthRepository _repository;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Attempts registration. Returns true on success; on failure sets [error]
  /// and returns false so the screen can surface a message.
  Future<bool> register({
    required String name,
    required String email,
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.register(
        RegisterRequestModel(
          name: name,
          email: email,
          username: username,
          password: password,
        ),
      );
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
}
