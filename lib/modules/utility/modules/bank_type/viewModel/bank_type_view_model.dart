import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../models/bank_type.dart';
import '../models/create_bank_type_request.dart';
import '../repository/bank_type_repository.dart';

/// Holds all bank type UI state.
///
/// Screens only ever interact with this class — never with the repository.
class BankTypeViewModel extends ChangeNotifier {
  BankTypeViewModel(this._repository);

  final BankTypeRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<BankType> _bankTypes = const [];
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<BankType> get bankTypes => _bankTypes;

  /// Bank types filtered by the current search query.
  List<BankType> get filteredBankTypes {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _bankTypes;
    return _bankTypes
        .where(
          (bankType) =>
              bankType.name.toLowerCase().contains(query) ||
              bankType.id.toString().contains(query) ||
              (bankType.description?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  Future<void> loadBankTypes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _bankTypes = await _repository.fetchBankTypes();
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

  Future<bool> addBankType(CreateBankTypeRequest request) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.createBankType(request);
      await loadBankTypes();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> deleteBankType(int id) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteBankType(id);
      await loadBankTypes();
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