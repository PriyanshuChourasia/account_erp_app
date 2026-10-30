import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../models/create_stock_item_request.dart';
import '../models/stock_item.dart';
import '../repository/stock_item_repository.dart';

/// Holds all stock item UI state.
///
/// Screens only ever interact with this class — never with the repository.
class StockItemViewModel extends ChangeNotifier {
  StockItemViewModel(this._repository);

  final StockItemRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<StockItem> _stockItems = const [];
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<StockItem> get stockItems => _stockItems;

  /// Stock items filtered by the current search query.
  List<StockItem> get filteredStockItems {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _stockItems;
    return _stockItems
        .where(
          (item) =>
              item.name.toLowerCase().contains(query) ||
              item.id.contains(query) ||
              (item.code?.toLowerCase().contains(query) ?? false) ||
              (item.alias?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  Future<void> loadStockItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _stockItems = await _repository.fetchStockItems();
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

  Future<bool> addStockItem(CreateStockItemRequest request) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.createStockItem(request);
      await loadStockItems();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> deleteStockItem(String id) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteStockItem(id);
      await loadStockItems();
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
