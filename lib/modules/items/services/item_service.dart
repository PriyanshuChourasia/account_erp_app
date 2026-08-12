import '../../../config/api_config.dart';
import '../../../network/api_service.dart';
import '../models/item.dart';

/// Raw HTTP calls for items. No parsing, no state.
class ItemService {
  ItemService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchItems() =>
      _apiService.get(ApiConfig.itemsEndpoint);

  Future<Map<String, dynamic>> createItem(Item item) =>
      _apiService.post(ApiConfig.itemsEndpoint, data: item.toJson());

  Future<Map<String, dynamic>> deleteItem(String id) =>
      _apiService.delete(ApiConfig.itemEndpoint(id));
}
