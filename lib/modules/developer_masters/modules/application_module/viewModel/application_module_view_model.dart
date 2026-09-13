import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../models/application_module.dart';
import '../models/create_application_module_request.dart';
import '../repository/application_module_repository.dart';

/// Holds all application module UI state.
///
/// Screens only ever interact with this class — never with the repository.
class ApplicationModuleViewModel extends ChangeNotifier {
  ApplicationModuleViewModel(this._repository);

  final ApplicationModuleRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<ApplicationModule> _applicationModules = const [];
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<ApplicationModule> get applicationModules => _applicationModules;

  /// Application modules filtered by the current search query.
  List<ApplicationModule> get filteredApplicationModules {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _applicationModules;
    return _applicationModules
        .where(
          (module) =>
              module.name.toLowerCase().contains(query) ||
              (module.code?.toLowerCase().contains(query) ?? false) ||
              (module.endpoint?.toLowerCase().contains(query) ?? false) ||
              (module.description?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  Future<void> loadApplicationModules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _applicationModules = await _repository.fetchApplicationModules();
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

  Future<bool> addApplicationModule(
    CreateApplicationModuleRequest request,
  ) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.createApplicationModule(request);
      await loadApplicationModules();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> deleteApplicationModule(String id) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteApplicationModule(id);
      await loadApplicationModules();
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
