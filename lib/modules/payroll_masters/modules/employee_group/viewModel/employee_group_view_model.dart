import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../models/create_employee_group_request.dart';
import '../models/employee_group.dart';
import '../repository/employee_group_repository.dart';

/// Holds all employee group UI state.
///
/// Screens only ever interact with this class — never with the repository.
class EmployeeGroupViewModel extends ChangeNotifier {
  EmployeeGroupViewModel(this._repository);

  final EmployeeGroupRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<EmployeeGroup> _employeeGroups = const [];
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<EmployeeGroup> get employeeGroups => _employeeGroups;

  /// Employee groups filtered by the current search query.
  List<EmployeeGroup> get filteredEmployeeGroups {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _employeeGroups;
    return _employeeGroups
        .where(
          (group) =>
              group.name.toLowerCase().contains(query) ||
              group.id.toLowerCase().contains(query) ||
              (group.code?.toLowerCase().contains(query) ?? false) ||
              (group.description?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  Future<void> loadEmployeeGroups() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _employeeGroups = await _repository.fetchEmployeeGroups();
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

  Future<bool> addEmployeeGroup(CreateEmployeeGroupRequest request) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.createEmployeeGroup(request);
      await loadEmployeeGroups();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> updateEmployeeGroup(
    String id,
    CreateEmployeeGroupRequest request,
  ) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.updateEmployeeGroup(id, request);
      await loadEmployeeGroups();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> deleteEmployeeGroup(String id) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteEmployeeGroup(id);
      await loadEmployeeGroups();
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
