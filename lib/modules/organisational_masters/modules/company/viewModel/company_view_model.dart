import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../models/company.dart';
import '../models/create_company_request.dart';
import '../repository/company_repository.dart';

/// Holds all company UI state.
///
/// Screens only ever interact with this class — never with the repository.
class CompanyViewModel extends ChangeNotifier {
  CompanyViewModel(this._repository);

  final CompanyRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<Company> _companies = const [];
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<Company> get companies => _companies;

  /// Companies filtered by the current search query.
  List<Company> get filteredCompanies {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _companies;
    return _companies
        .where(
          (company) =>
              company.name.toLowerCase().contains(query) ||
              company.id.toString().contains(query) ||
              (company.code?.toLowerCase().contains(query) ?? false) ||
              (company.alias?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  Future<void> loadCompanies() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _companies = await _repository.fetchCompanies();
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

  Future<bool> addCompany(CreateCompanyRequest request) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.createCompany(request);
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> deleteCompany(int id) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteCompany(id);
      await loadCompanies();
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
