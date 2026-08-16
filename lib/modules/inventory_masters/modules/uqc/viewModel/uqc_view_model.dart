import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../models/create_uqc_request.dart';
import '../models/update_uqc_request.dart';
import '../models/uqc.dart';
import '../repository/uqc_repository.dart';

/// Holds all UQC UI state.
///
/// Screens only ever interact with this class — never with the repository.
class UqcViewModel extends ChangeNotifier {
  UqcViewModel(this._repository);

  final UqcRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<Uqc> _uqcs = const [];
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<Uqc> get uqcs => _uqcs;

  /// UQCs filtered by the current search query.
  List<Uqc> get filteredUqcs {
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

  Future<void> loadUqcs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _uqcs = await _repository.fetchUqcs();
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

  Future<bool> addUqc(CreateUqcRequest request) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.createUqc(request);
      await loadUqcs();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> updateUqc(UpdateUqcRequest request) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.updateUqc(request);
      await loadUqcs();
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
