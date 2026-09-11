import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../../bank_type/models/bank_type.dart';
import '../../bank_type/repository/bank_type_repository.dart';
import '../models/bank.dart';
import '../models/create_bank_request.dart';
import '../repository/bank_repository.dart';

/// Holds all bank UI state.
///
/// Screens only ever interact with this class — never with the repository.
/// Also loads the bank type list (via [BankTypeRepository]) so the UI can
/// resolve bank type names and offer a type picker.
class BankViewModel extends ChangeNotifier {
  BankViewModel(this._repository, this._bankTypeRepository);

  final BankRepository _repository;
  final BankTypeRepository _bankTypeRepository;

  bool _isLoading = false;
  String? _error;
  List<Bank> _banks = const [];
  List<BankType> _bankTypes = const [];
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<Bank> get banks => _banks;
  List<BankType> get bankTypes => _bankTypes;

  /// Resolves a bank type name for a bank, falling back to the bank's own
  /// `bankTypeName` (when the backend sends it) or `—`.
  String bankTypeNameOf(Bank bank) {
    final bankType = _bankTypes
        .where((candidate) => candidate.id == bank.bankTypeId)
        .firstOrNull;
    return bankType?.name ?? bank.bankTypeName ?? '—';
  }

  /// Banks filtered by the current search query.
  List<Bank> get filteredBanks {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _banks;
    return _banks
        .where(
          (bank) =>
              bank.name.toLowerCase().contains(query) ||
              bank.id.toString().contains(query) ||
              (bank.code?.toLowerCase().contains(query) ?? false) ||
              bankTypeNameOf(bank).toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> loadBanks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _banks = await _repository.fetchBanks();
    } on AppException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBankTypes() async {
    try {
      _bankTypes = await _bankTypeRepository.fetchBankTypes();
    } catch (_) {
      _bankTypes = const [];
    }
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<bool> addBank(CreateBankRequest request) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.createBank(request);
      await loadBanks();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> deleteBank(int id) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteBank(id);
      await loadBanks();
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