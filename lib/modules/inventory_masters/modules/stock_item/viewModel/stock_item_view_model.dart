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

  /// Index of the multi-step create form the user is currently on.
  int _currentStep = 0;

  /// Draft request backing the multi-step create form.
  CreateStockItemRequest draft = const CreateStockItemRequest(
    name: '',
    unitId: '',
  );

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<StockItem> get stockItems => _stockItems;

  int get currentStep => _currentStep;

  /// Number of steps in the stock item create wizard.
  int get stepCount => 3;

  /// Moves the stock item create wizard to [step].
  void goToStep(int step) {
    _currentStep = step.clamp(0, stepCount - 1);
    notifyListeners();
  }

  /// Advances the stock item create wizard to the next step.
  void next() {
    if (_currentStep < stepCount - 1) {
      _currentStep += 1;
      notifyListeners();
    }
  }

  /// Moves the stock item create wizard back one step.
  void back() {
    if (_currentStep > 0) {
      _currentStep -= 1;
      notifyListeners();
    }
  }

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
