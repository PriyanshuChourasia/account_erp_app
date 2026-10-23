import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../models/create_department_request.dart';
import '../models/department.dart';
import '../repository/department_repository.dart';

/// Holds all department UI state.
///
/// Screens only ever interact with this class — never with the repository.
class DepartmentViewModel extends ChangeNotifier {
  DepartmentViewModel(this._repository);

  final DepartmentRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<Department> _departments = const [];
  String _query = '';
  int _page = 0;
  int _rowsPerPage = 10;
  final Set<String> _togglingIds = {};

  /// Page-size choices offered by the table footer.
  static const List<int> rowsPerPageOptions = [10, 25, 50];

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<Department> get departments => _departments;

  /// Zero-based index of the current page.
  int get page => _page;
  int get rowsPerPage => _rowsPerPage;

  /// Number of pages for the filtered list (at least 1).
  int get pageCount {
    final total = filteredDepartments.length;
    return total == 0 ? 1 : (total / _rowsPerPage).ceil();
  }

  /// The slice of [filteredDepartments] shown on the current page.
  List<Department> get pagedDepartments {
    final filtered = filteredDepartments;
    final start = _page * _rowsPerPage;
    if (start >= filtered.length) return const [];
    final end = (start + _rowsPerPage).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  /// Whether a status change for [id] is in flight.
  bool isToggling(String id) => _togglingIds.contains(id);

  /// Departments filtered by the current search query.
  List<Department> get filteredDepartments {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _departments;
    return _departments
        .where(
          (department) =>
              department.name.toLowerCase().contains(query) ||
              department.id.contains(query) ||
              (department.code?.toLowerCase().contains(query) ?? false) ||
              (department.description?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  Future<void> loadDepartments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _departments = await _repository.fetchDepartments();
      // Stay on the same page after a reload unless it no longer exists.
      _page = _page.clamp(0, pageCount - 1);
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
    _page = 0;
    notifyListeners();
  }

  void setPage(int value) {
    _page = value.clamp(0, pageCount - 1);
    notifyListeners();
  }

  void setRowsPerPage(int value) {
    _rowsPerPage = value;
    _page = 0;
    notifyListeners();
  }

  /// Switches [department] active/inactive via the update endpoint, then
  /// reloads so the list reflects what the backend actually stored.
  Future<bool> setActive(Department department, bool active) async {
    _togglingIds.add(department.id);
    _error = null;
    notifyListeners();
    try {
      await _repository.updateDepartment(
        department.id,
        CreateDepartmentRequest(
          name: department.name,
          code: department.code,
          description: department.description,
          active: active,
        ),
      );
      await loadDepartments();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _togglingIds.remove(department.id);
      notifyListeners();
    }
  }

  Future<bool> addDepartment(CreateDepartmentRequest request) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.createDepartment(request);
      await loadDepartments();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> updateDepartment(
    String id,
    CreateDepartmentRequest request,
  ) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.updateDepartment(id, request);
      await loadDepartments();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> deleteDepartment(String id) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteDepartment(id);
      await loadDepartments();
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
