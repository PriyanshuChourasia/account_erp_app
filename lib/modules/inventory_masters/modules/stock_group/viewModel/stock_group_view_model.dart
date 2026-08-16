import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../models/stock_group.dart';
import '../repository/stock_group_repository.dart';

/// Holds all stock group UI state.
///
/// Screens only ever interact with this class — never with the repository.
class StockGroupViewModel extends ChangeNotifier {
  StockGroupViewModel(this._repository);

  final StockGroupRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<StockGroup> _stockGroups = const [];
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<StockGroup> get stockGroups => _stockGroups;

  /// Stock groups filtered by the current search query.
  List<StockGroup> get filteredStockGroups {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _stockGroups;
    return _stockGroups
        .where(
          (group) =>
              group.name.toLowerCase().contains(query) ||
              group.id.toString().contains(query) ||
              (group.code?.toLowerCase().contains(query) ?? false) ||
              (group.alias?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  Future<void> loadStockGroups() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _stockGroups = await _repository.fetchStockGroups();
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

  Future<bool> addStockGroup({
    required String name,
    String? code,
    String? alias,
    int? parentId,
    String? description,
    bool shouldAddQuantities = false,
    bool setAlterGstDetail = false,
  }) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.createStockGroup(
        name: name,
        code: code,
        alias: alias,
        parentId: parentId,
        description: description,
        shouldAddQuantities: shouldAddQuantities,
        setAlterGstDetail: setAlterGstDetail,
      );
      await loadStockGroups();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> deleteStockGroup(int id) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteStockGroup(id);
      await loadStockGroups();
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
