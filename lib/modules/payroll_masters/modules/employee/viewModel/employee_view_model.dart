import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../models/create_employee_request.dart';
import '../models/employee.dart';
import '../repository/employee_repository.dart';

/// Holds all employee UI state.
///
/// Screens only ever interact with this class — never with the repository.
class EmployeeViewModel extends ChangeNotifier {
  EmployeeViewModel(this._repository);

  final EmployeeRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<Employee> _employees = const [];
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<Employee> get employees => _employees;

  /// Employees filtered by the current search query.
  List<Employee> get filteredEmployees {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _employees;
    return _employees
        .where(
          (employee) =>
              employee.name.toLowerCase().contains(query) ||
              employee.id.toLowerCase().contains(query) ||
              (employee.employeeCode?.toLowerCase().contains(query) ?? false) ||
              (employee.email?.toLowerCase().contains(query) ?? false) ||
              (employee.designation?.toLowerCase().contains(query) ?? false) ||
              (employee.department?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  Future<void> loadEmployees() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _employees = await _repository.fetchEmployees();
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

  Future<bool> addEmployee(CreateEmployeeRequest request) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.createEmployee(request);
      await loadEmployees();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> deleteEmployee(String id) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteEmployee(id);
      await loadEmployees();
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
