import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../models/application_feature.dart';
import '../models/create_application_feature_request.dart';
import '../repository/application_feature_repository.dart';

/// Holds all application feature UI state.
///
/// Screens only ever interact with this class — never with the repository.
class ApplicationFeatureViewModel extends ChangeNotifier {
  ApplicationFeatureViewModel(this._repository);

  final ApplicationFeatureRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<ApplicationFeature> _applicationFeatures = const [];
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<ApplicationFeature> get applicationFeatures => _applicationFeatures;

  /// Application features filtered by the current search query.
  List<ApplicationFeature> get filteredApplicationFeatures {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _applicationFeatures;
    return _applicationFeatures
        .where(
          (feature) =>
              feature.name.toLowerCase().contains(query) ||
              feature.endPoint.toLowerCase().contains(query) ||
              (feature.code?.toString().contains(query) ?? false) ||
              (feature.description?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  Future<void> loadApplicationFeatures() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _applicationFeatures = await _repository.fetchApplicationFeatures();
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

  Future<bool> addApplicationFeature(
    CreateApplicationFeatureRequest request,
  ) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.createApplicationFeature(request);
      await loadApplicationFeatures();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> deleteApplicationFeature(String id) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteApplicationFeature(id);
      await loadApplicationFeatures();
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
