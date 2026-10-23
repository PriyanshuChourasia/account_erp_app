import 'package:flutter/foundation.dart';

import '../../../core/app_exception.dart';
import '../models/register_request_model.dart';
import '../repository/auth_repository.dart';

/// Holds the sign-up form's UI state.
///
/// Only `RegisterDialog` needs this, so it is scoped to that dialog rather
/// than registered in the root `MultiProvider`.
class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel(this._repository);

  final AuthRepository _repository;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Attempts registration. Returns true on success (the session token is
  /// then stored); on failure sets [error] and returns false.
  Future<bool> register(RegisterRequestModel request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.register(request);
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
