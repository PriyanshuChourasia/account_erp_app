import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../models/account_group.dart';
import '../models/create_account_group_request.dart';
import '../repository/account_group_repository.dart';

/// Holds all accounting group UI state.
///
/// Screens only ever interact with this class — never with the repository.
class AccountGroupViewModel extends ChangeNotifier {
  AccountGroupViewModel(this._repository);

  final AccountGroupRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<AccountGroup> _accountingGroups = const [];
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<AccountGroup> get accountingGroups => _accountingGroups;

  /// Accounting groups filtered by the current search query.
  List<AccountGroup> get filteredAccountGroups {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _accountingGroups;
    return _accountingGroups
        .where((group) =>
            group.name.toLowerCase().contains(query) ||
            group.id.toString().contains(query) ||
            (group.alias?.toLowerCase().contains(query) ?? false))
        .toList();
  }

  Future<void> loadAccountGroups() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _accountingGroups = await _repository.fetchAccountGroups();
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

  Future<bool> addAccountGroup(CreateAccountGroupRequest request) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.createAccountGroup(request);
      await loadAccountGroups();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> deleteAccountGroup(int id) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteAccountGroup(id);
      await loadAccountGroups();
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
