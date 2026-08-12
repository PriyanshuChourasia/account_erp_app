import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../models/create_unit_request.dart';
import '../models/unit.dart';
import '../repository/unit_repository.dart';

/// Holds all unit UI state.
///
/// Screens only ever interact with this class — never with the repository.
class UnitViewModel extends ChangeNotifier {
  UnitViewModel(this._repository);

  final UnitRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<Unit> _units = const [];
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<Unit> get units => _units;

  /// Units filtered by the current search query.
  List<Unit> get filteredUnits {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _units;
    return _units
        .where((unit) =>
            unit.name.toLowerCase().contains(query) ||
            unit.id.toString().contains(query) ||
            (unit.code?.toLowerCase().contains(query) ?? false))
        .toList();
  }

  Future<void> loadUnits() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _units = await _repository.fetchUnits();
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

  Future<bool> addUnit(CreateUnitRequest request) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.createUnit(request);
      await loadUnits();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> deleteUnit(int id) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteUnit(id);
      await loadUnits();
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
