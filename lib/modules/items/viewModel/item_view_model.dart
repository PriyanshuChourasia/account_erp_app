import 'package:flutter/foundation.dart';

import '../models/item.dart';
import '../repository/item_repository.dart';

/// Holds all item list UI state.
///
/// Screens only ever interact with this class — never with the repository.
class ItemViewModel extends ChangeNotifier {
  ItemViewModel(this._repository);

  final ItemRepository _repository;

  bool _isLoading = false;
  List<Item> _items = const [];
  String _query = '';

  bool get isLoading => _isLoading;
  String get query => _query;
  List<Item> get items => _items;

  /// Items filtered by the current search query.
  List<Item> get filteredItems {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _items;
    return _items.where((item) =>
        item.name.toLowerCase().contains(query) ||
        item.category.toLowerCase().contains(query) ||
        item.id.toLowerCase().contains(query)).toList();
  }

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();
    _items = await _repository.fetchItems();
    _isLoading = false;
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<void> addItem({
    required String name,
    required String category,
    required double price,
    required int stock,
  }) async {
    final id = 'ITM-${(_items.length + 1).toString().padLeft(3, '0')}';
    final item = Item(
      id: id,
      name: name,
      category: category,
      price: price,
      stock: stock,
    );
    await _repository.createItem(item);
    _items = [..._items, item];
    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    await _repository.deleteItem(id);
    _items = _items.where((item) => item.id != id).toList();
    notifyListeners();
  }
}
