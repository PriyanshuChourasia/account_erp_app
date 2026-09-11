import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../../bank/models/bank.dart';
import '../../bank/repository/bank_repository.dart';
import '../models/bank_branch.dart';
import '../models/create_bank_branch_request.dart';
import '../repository/bank_branch_repository.dart';

/// Holds all bank branch UI state.
///
/// Screens only ever interact with this class — never with the repository.
/// Also loads the bank list (via [BankRepository]) so the UI can resolve bank
/// names and offer a bank picker.
class BankBranchViewModel extends ChangeNotifier {
  BankBranchViewModel(this._repository, this._bankRepository);

  final BankBranchRepository _repository;
  final BankRepository _bankRepository;

  bool _isLoading = false;
  String? _error;
  List<BankBranch> _bankBranches = const [];
  List<Bank> _banks = const [];
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<BankBranch> get bankBranches => _bankBranches;
  List<Bank> get banks => _banks;

  /// Resolves a bank name for a branch, falling back to the branch's own
  /// `bankName` (when the backend sends it) or `—`.
  String bankNameOf(BankBranch branch) {
    final bank = _banks.where((candidate) => candidate.id == branch.bankId).firstOrNull;
    return bank?.name ?? branch.bankName ?? '—';
  }

  /// Bank branches filtered by the current search query.
  List<BankBranch> get filteredBankBranches {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _bankBranches;
    return _bankBranches
        .where(
          (branch) =>
              branch.name.toLowerCase().contains(query) ||
              branch.id.toString().contains(query) ||
              (branch.ifscCode?.toLowerCase().contains(query) ?? false) ||
              bankNameOf(branch).toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> loadBankBranches() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _bankBranches = await _repository.fetchBankBranches();
    } on AppException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBanks() async {
    try {
      _banks = await _bankRepository.fetchBanks();
    } catch (_) {
      _banks = const [];
    }
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<bool> addBankBranch(CreateBankBranchRequest request) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.createBankBranch(request);
      await loadBankBranches();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> deleteBankBranch(int id) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteBankBranch(id);
      await loadBankBranches();
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