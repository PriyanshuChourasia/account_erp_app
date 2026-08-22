import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../../country/models/country.dart';
import '../../country/repository/country_repository.dart';
import '../models/create_state_request.dart';
import '../models/state_master.dart';
import '../repository/state_repository.dart';

/// Holds all state UI state.
///
/// Screens only ever interact with this class — never with the repository.
/// Also loads the country list (via [CountryRepository]) so the UI can
/// resolve country names and offer a country picker.
class StateViewModel extends ChangeNotifier {
  StateViewModel(this._repository, this._countryRepository);

  final StateRepository _repository;
  final CountryRepository _countryRepository;

  bool _isLoading = false;
  String? _error;
  List<StateMaster> _states = const [];
  List<Country> _countries = const [];
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<StateMaster> get states => _states;
  List<Country> get countries => _countries;

  /// Resolves a country name for a state, falling back to the state's own
  /// `countryName` (when the backend sends it) or `—`.
  String countryNameOf(StateMaster state) {
    final country = _countries
        .where((candidate) => candidate.id == state.countryId)
        .firstOrNull;
    return country?.name ?? state.countryName ?? '—';
  }

  /// States filtered by the current search query.
  List<StateMaster> get filteredStates {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _states;
    return _states
        .where(
          (state) =>
              state.name.toLowerCase().contains(query) ||
              state.id.toString().contains(query) ||
              (state.code?.toLowerCase().contains(query) ?? false) ||
              countryNameOf(state).toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> loadStates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _states = await _repository.fetchStates();
    } on AppException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCountries() async {
    try {
      _countries = await _countryRepository.fetchCountries();
    } catch (_) {
      _countries = const [];
    }
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<bool> addState(CreateStateRequest request) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.createState(request);
      await loadStates();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> deleteState(String id) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteState(id);
      await loadStates();
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
