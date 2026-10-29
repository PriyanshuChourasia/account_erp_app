import '../../../../../network/api_service.dart';
import '../../../configs/inventory_api_config.dart';
import '../models/create_stock_item_request.dart';

/// Raw HTTP calls for stock items. No parsing, no state.
class StockItemService {
  StockItemService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchStockItems() =>
      _apiService.get(InventoryApiConfig.stockItemAPI);

  Future<Map<String, dynamic>> createStockItem(
    CreateStockItemRequest request,
  ) => _apiService.post(
    InventoryApiConfig.createStockItemAPI,
    data: request.toJson(),
  );

  Future<Map<String, dynamic>> deleteStockItem(String id) =>
      _apiService.delete(InventoryApiConfig.stockItemEndpoint(id));
}
