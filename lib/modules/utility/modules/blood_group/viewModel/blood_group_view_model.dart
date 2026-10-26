import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../models/blood_group.dart';
import '../models/create_blood_group_request.dart';
import '../repository/blood_group_repository.dart';

/// Holds all blood group UI state.
///
/// Screens only ever interact with this class — never with the repository.
class BloodGroupViewModel extends ChangeNotifier {
  BloodGroupViewModel(this._repository);

  final BloodGroupRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<BloodGroup> _bloodGroups = const [];
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<BloodGroup> get bloodGroups => _bloodGroups;

  /// Blood groups filtered by the current search query.
  List<BloodGroup> get filteredBloodGroups {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _bloodGroups;
    return _bloodGroups
        .where(
          (bloodGroup) =>
              bloodGroup.name.toLowerCase().contains(query) ||
              bloodGroup.id.toString().contains(query) ||
              (bloodGroup.code?.toLowerCase().contains(query) ?? false) ||
              (bloodGroup.description?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  Future<void> loadBloodGroups() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _bloodGroups = await _repository.fetchBloodGroups();
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

  Future<bool> addBloodGroup(CreateBloodGroupRequest request) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.createBloodGroup(request);
      await loadBloodGroups();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> deleteBloodGroup(int id) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteBloodGroup(id);
      await loadBloodGroups();
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
