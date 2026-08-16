import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../models/create_unique_quantity_code_request.dart';
import '../models/update_unique_quantity_code_request.dart';
import '../models/unique_quantity_code.dart';
import '../repository/unique_quantity_code_repository.dart';

/// Holds all UQC UI state.
///
/// Screens only ever interact with this class — never with the repository.
class UniqueQuantityCodeViewModel extends ChangeNotifier {
  UniqueQuantityCodeViewModel(this._repository);

  final UniqueQuantityCodeRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<UniqueQuantityCode> _uqcs = const [];
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<UniqueQuantityCode> get uqcs => _uqcs;

  /// UQCs filtered by the current search query.
  List<UniqueQuantityCode> get filteredUniqueQuantityCodes {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _uqcs;
    return _uqcs
        .where(
          (uqc) =>
              uqc.name.toLowerCase().contains(query) ||
              uqc.id.toString().contains(query) ||
              (uqc.code?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  Future<void> loadUniqueQuantityCodes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _uqcs = await _repository.fetchUniqueQuantityCodes();
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

  Future<bool> addUniqueQuantityCode(
    CreateUniqueQuantityCodeRequest request,
  ) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.createUniqueQuantityCode(request);
      await loadUniqueQuantityCodes();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> updateUniqueQuantityCode(
    UpdateUniqueQuantityCodeRequest request,
  ) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.updateUniqueQuantityCode(request);
      await loadUniqueQuantityCodes();
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
