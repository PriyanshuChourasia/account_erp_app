import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../models/create_gender_request.dart';
import '../models/gender.dart';
import '../repository/gender_repository.dart';

/// Holds all gender UI state.
///
/// Screens only ever interact with this class — never with the repository.
class GenderViewModel extends ChangeNotifier {
  GenderViewModel(this._repository);

  final GenderRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<Gender> _genders = const [];
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<Gender> get genders => _genders;

  /// Genders filtered by the current search query.
  List<Gender> get filteredGenders {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _genders;
    return _genders
        .where(
          (gender) =>
              gender.name.toLowerCase().contains(query) ||
              (gender.code?.toLowerCase().contains(query) ?? false) ||
              (gender.description?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  Future<void> loadGenders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _genders = await _repository.fetchGenders();
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

  Future<bool> addGender(CreateGenderRequest request) =>
      _run(() => _repository.createGender(request));

  Future<bool> updateGender(String id, CreateGenderRequest request) =>
      _run(() => _repository.updateGender(id, request));

  Future<bool> deleteGender(String id) =>
      _run(() => _repository.deleteGender(id));

  /// Runs a write, then reloads the list. Returns whether it succeeded.
  Future<bool> _run(Future<void> Function() action) async {
    _error = null;
    notifyListeners();
    try {
      await action();
      await loadGenders();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }
}
