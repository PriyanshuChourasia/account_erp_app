import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../models/create_stock_category_request.dart';
import '../models/stock_category.dart';
import '../repository/stock_category_repository.dart';

/// Holds all stock category UI state.
///
/// Screens only ever interact with this class — never with the repository.
class StockCategoryViewModel extends ChangeNotifier {
  StockCategoryViewModel(this._repository);

  final StockCategoryRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<StockCategory> _stockCategories = const [];
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<StockCategory> get stockCategories => _stockCategories;

  /// Stock categories filtered by the current search query.
  List<StockCategory> get filteredStockCategories {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _stockCategories;
    return _stockCategories
        .where(
          (category) =>
              category.name.toLowerCase().contains(query) ||
              category.id.toString().contains(query) ||
              (category.code?.toLowerCase().contains(query) ?? false) ||
              (category.alias?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  Future<void> loadStockCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _stockCategories = await _repository.fetchStockCategories();
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

  Future<bool> addStockCategory(CreateStockCategoryRequest request) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.createStockCategory(request);
      await loadStockCategories();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> deleteStockCategory(int id) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteStockCategory(id);
      await loadStockCategories();
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
