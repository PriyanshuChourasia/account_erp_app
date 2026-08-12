import '../models/item.dart';

/// Orchestrates item data.
///
/// NOTE: Demo-backed until the backend is wired. TODO: swap the in-memory list
/// for `ItemService` calls (already registered in `network/service_locator.dart`)
/// and unwrap the `ResponseModelWrapper` envelope, mirroring `AuthRepository`.
class ItemRepository {
  ItemRepository();

  final List<Item> _items = List.of(Item.demo);

  Future<List<Item>> fetchItems() async => List.unmodifiable(_items);

  Future<void> createItem(Item item) async => _items.add(item);

  Future<void> deleteItem(String id) async {
    _items.removeWhere((item) => item.id == id);
  }
}
