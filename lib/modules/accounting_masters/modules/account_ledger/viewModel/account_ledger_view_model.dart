import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../../account_group/models/account_group.dart';
import '../../account_group/repository/account_group_repository.dart';
import '../models/account_ledger.dart';
import '../models/create_account_ledger_request.dart';
import '../repository/account_ledger_repository.dart';

/// Holds all account ledger UI state.
///
/// Screens only ever interact with this class — never with the repository.
/// Also loads the account group list (via [AccountGroupRepository]) so the UI
/// can resolve group names and offer a group picker.
class AccountLedgerViewModel extends ChangeNotifier {
  AccountLedgerViewModel(this._repository, this._accountGroupRepository);

  final AccountLedgerRepository _repository;
  final AccountGroupRepository _accountGroupRepository;

  bool _isLoading = false;
  String? _error;
  List<AccountLedger> _accountLedgers = const [];
  List<AccountGroup> _accountGroups = const [];
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<AccountLedger> get accountLedgers => _accountLedgers;
  List<AccountGroup> get accountGroups => _accountGroups;

  /// Resolves a group name for a ledger, falling back to the ledger's own
  /// `groupName` (when the backend sends it) or `—`.
  String groupNameOf(AccountLedger ledger) {
    final group = _accountGroups
        .where((candidate) => candidate.id == ledger.groupId)
        .firstOrNull;
    return group?.name ?? ledger.groupName ?? '—';
  }

  /// Account ledgers filtered by the current search query.
  List<AccountLedger> get filteredAccountLedgers {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _accountLedgers;
    return _accountLedgers
        .where((ledger) =>
            ledger.name.toLowerCase().contains(query) ||
            ledger.id.toString().contains(query) ||
            (ledger.alias?.toLowerCase().contains(query) ?? false) ||
            groupNameOf(ledger).toLowerCase().contains(query))
        .toList();
  }

  Future<void> loadAccountLedgers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _accountLedgers = await _repository.fetchAccountLedgers();
    } on AppException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAccountGroups() async {
    try {
      _accountGroups = await _accountGroupRepository.fetchAccountGroups();
    } catch (_) {
      _accountGroups = const [];
    }
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<bool> addAccountLedger(CreateAccountLedgerRequest request) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.createAccountLedger(request);
      await loadAccountLedgers();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> deleteAccountLedger(int id) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteAccountLedger(id);
      await loadAccountLedgers();
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
