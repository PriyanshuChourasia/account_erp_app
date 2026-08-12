import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../models/country.dart';
import '../models/create_country_request.dart';
import '../repository/country_repository.dart';

/// Holds all country UI state.
///
/// Screens only ever interact with this class — never with the repository.
class CountryViewModel extends ChangeNotifier {
  CountryViewModel(this._repository);

  final CountryRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<Country> _countries = const [];
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<Country> get countries => _countries;

  /// Countries filtered by the current search query.
  List<Country> get filteredCountries {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _countries;
    return _countries
        .where((country) =>
            country.name.toLowerCase().contains(query) ||
            country.id.toString().contains(query) ||
            (country.code?.toLowerCase().contains(query) ?? false) ||
            (country.alias?.toLowerCase().contains(query) ?? false))
        .toList();
  }

  Future<void> loadCountries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _countries = await _repository.fetchCountries();
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

  Future<bool> addCountry(CreateCountryRequest request) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.createCountry(request);
      await loadCountries();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> deleteCountry(int id) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteCountry(id);
      await loadCountries();
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
