import '../../../../../config/api_config.dart';
import '../../../../../network/api_service.dart';

/// Raw HTTP calls for stock items. No parsing, no state.
class StockItemService {
  StockItemService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchStockItems() =>
      _apiService.get(ApiConfig.stockItemsEndpoint);

  Future<Map<String, dynamic>> createStockItem(Map<String, dynamic> data) =>
      _apiService.post(ApiConfig.stockItemCreateEndpoint, data: data);

  Future<Map<String, dynamic>> deleteStockItem(int id) =>
      _apiService.delete(ApiConfig.stockItemEndpoint(id));
}
