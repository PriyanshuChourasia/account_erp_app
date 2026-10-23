import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../models/create_designation_request.dart';
import '../models/designation.dart';
import '../repository/designation_repository.dart';

/// Holds all designation UI state.
///
/// Screens only ever interact with this class — never with the repository.
class DesignationViewModel extends ChangeNotifier {
  DesignationViewModel(this._repository);

  final DesignationRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<Designation> _designations = const [];
  String _query = '';
  int _page = 0;
  int _rowsPerPage = 10;
  final Set<String> _togglingIds = {};

  /// Page-size choices offered by the table footer.
  static const List<int> rowsPerPageOptions = [10, 25, 50];

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<Designation> get designations => _designations;

  /// Zero-based index of the current page.
  int get page => _page;
  int get rowsPerPage => _rowsPerPage;

  /// Number of pages for the filtered list (at least 1).
  int get pageCount {
    final total = filteredDesignations.length;
    return total == 0 ? 1 : (total / _rowsPerPage).ceil();
  }

  /// The slice of [filteredDesignations] shown on the current page.
  List<Designation> get pagedDesignations {
    final filtered = filteredDesignations;
    final start = _page * _rowsPerPage;
    if (start >= filtered.length) return const [];
    final end = (start + _rowsPerPage).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  /// Whether a status change for [id] is in flight.
  bool isToggling(String id) => _togglingIds.contains(id);

  /// Designations filtered by the current search query.
  List<Designation> get filteredDesignations {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _designations;
    return _designations
        .where(
          (designation) =>
              designation.name.toLowerCase().contains(query) ||
              designation.id.contains(query) ||
              (designation.code?.toLowerCase().contains(query) ?? false) ||
              (designation.description?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  Future<void> loadDesignations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _designations = await _repository.fetchDesignations();
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

  /// Switches [designation] active/inactive via the update endpoint, then
  /// reloads so the list reflects what the backend actually stored.
  Future<bool> setActive(Designation designation, bool active) async {
    _togglingIds.add(designation.id);
    _error = null;
    notifyListeners();
    try {
      await _repository.updateDesignation(
        designation.id,
        CreateDesignationRequest(
          name: designation.name,
          code: designation.code,
          description: designation.description,
          active: active,
        ),
      );
      await loadDesignations();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _togglingIds.remove(designation.id);
      notifyListeners();
    }
  }

  Future<bool> addDesignation(CreateDesignationRequest request) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.createDesignation(request);
      await loadDesignations();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> updateDesignation(
    String id,
    CreateDesignationRequest request,
  ) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.updateDesignation(id, request);
      await loadDesignations();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> deleteDesignation(String id) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteDesignation(id);
      await loadDesignations();
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
