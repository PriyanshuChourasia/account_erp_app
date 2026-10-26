import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../models/create_employee_category_request.dart';
import '../models/employee_category.dart';
import '../repository/employee_category_repository.dart';

/// Holds all employee category UI state.
///
/// Screens only ever interact with this class — never with the repository.
class EmployeeCategoryViewModel extends ChangeNotifier {
  EmployeeCategoryViewModel(this._repository);

  final EmployeeCategoryRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<EmployeeCategory> _employeeCategories = const [];
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<EmployeeCategory> get employeeCategories => _employeeCategories;

  /// Employee categories filtered by the current search query.
  List<EmployeeCategory> get filteredEmployeeCategories {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _employeeCategories;
    return _employeeCategories
        .where(
          (category) =>
              category.name.toLowerCase().contains(query) ||
              category.id.toLowerCase().contains(query) ||
              (category.alias?.toLowerCase().contains(query) ?? false) ||
              (category.description?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  Future<void> loadEmployeeCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _employeeCategories = await _repository.fetchEmployeeCategories();
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

  Future<bool> addEmployeeCategory(
    CreateEmployeeCategoryRequest request,
  ) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.createEmployeeCategory(request);
      await loadEmployeeCategories();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> updateEmployeeCategory(
    String id,
    CreateEmployeeCategoryRequest request,
  ) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.updateEmployeeCategory(id, request);
      await loadEmployeeCategories();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> deleteEmployeeCategory(String id) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteEmployeeCategory(id);
      await loadEmployeeCategories();
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
