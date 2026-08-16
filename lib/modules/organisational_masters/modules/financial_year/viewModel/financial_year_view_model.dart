import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../models/create_financial_year_request.dart';
import '../models/financial_year.dart';
import '../repository/financial_year_repository.dart';

/// Holds all financial year UI state.
///
/// Screens only ever interact with this class — never with the repository.
class FinancialYearViewModel extends ChangeNotifier {
  FinancialYearViewModel(this._repository);

  final FinancialYearRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<FinancialYear> _financialYears = const [];
  String _query = '';
  int? _selectedYearId;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<FinancialYear> get financialYears => _financialYears;

  /// The financial year currently selected in the app header.
  ///
  /// Defaults to the year flagged `isCurrent` once the list loads; null until
  /// then or when the list is empty.
  FinancialYear? get selectedFinancialYear {
    final id = _selectedYearId;
    if (id == null) return null;
    for (final year in _financialYears) {
      if (year.id == id) return year;
    }
    return null;
  }

  void selectFinancialYear(FinancialYear year) {
    if (_selectedYearId == year.id) return;
    _selectedYearId = year.id;
    notifyListeners();
  }

  /// Financial years filtered by the current search query.
  List<FinancialYear> get filteredFinancialYears {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _financialYears;
    return _financialYears
        .where(
          (year) =>
              year.name.toLowerCase().contains(query) ||
              year.id.toString().contains(query) ||
              (year.code?.toLowerCase().contains(query) ?? false) ||
              (year.startDate?.contains(query) ?? false) ||
              (year.endDate?.contains(query) ?? false),
        )
        .toList();
  }

  Future<void> loadFinancialYears() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _financialYears = await _repository.fetchFinancialYears();
      _ensureSelection();
    } on AppException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Keeps the selection valid after the list changes: keeps the current pick
  /// when still present, otherwise falls back to the `isCurrent` year and
  /// finally to the first available year.
  void _ensureSelection() {
    if (_financialYears.any((year) => year.id == _selectedYearId)) return;
    FinancialYear? fallback;
    for (final year in _financialYears) {
      if (year.isCurrent) {
        fallback = year;
        break;
      }
    }
    fallback ??= _financialYears.isEmpty ? null : _financialYears.first;
    _selectedYearId = fallback?.id;
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<bool> addFinancialYear(CreateFinancialYearRequest request) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.createFinancialYear(request);
      await loadFinancialYears();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> setCurrentFinancialYear(FinancialYear year, bool current) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.updateCurrentFinancialYear(year.id, current);
      await loadFinancialYears();
      if (current) selectFinancialYear(year);
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
