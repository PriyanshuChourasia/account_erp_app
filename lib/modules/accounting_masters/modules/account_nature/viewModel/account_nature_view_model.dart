import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../models/account_nature.dart';
import '../models/create_account_nature_request.dart';
import '../repository/account_nature_repository.dart';

/// Holds all account nature UI state.
///
/// Screens only ever interact with this class — never with the repository.
class AccountNatureViewModel extends ChangeNotifier {
  AccountNatureViewModel(this._repository);

  final AccountNatureRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<AccountNature> _accountNatures = const [];
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<AccountNature> get accountNatures => _accountNatures;

  /// Account natures filtered by the current search query.
  List<AccountNature> get filteredAccountNatures {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _accountNatures;
    return _accountNatures
        .where((nature) =>
            nature.name.toLowerCase().contains(query) ||
            nature.id.toString().contains(query) ||
            (nature.code?.toString().contains(query) ?? false) ||
            (nature.description?.toLowerCase().contains(query) ?? false))
        .toList();
  }

  Future<void> loadAccountNatures() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _accountNatures = await _repository.fetchAccountNatures();
    } on AppException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<bool> addAccountNature(CreateAccountNatureRequest request) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.createAccountNature(request);
      await loadAccountNatures();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> deleteAccountNature(int id) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteAccountNature(id);
      await loadAccountNatures();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }
}
