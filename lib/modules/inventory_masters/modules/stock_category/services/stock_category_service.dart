import 'package:account_erp_app/modules/inventory_masters/configs/inventory_api_config.dart';

import '../../../../../config/api_config.dart';
import '../../../../../network/api_service.dart';
import '../models/create_stock_category_request.dart';

/// Raw HTTP calls for stock categories. No parsing, no state.
class StockCategoryService {
  StockCategoryService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchStockCategories() =>
      _apiService.get(InventoryApiConfig.stockCategoryListAPI);

  Future<Map<String,dynamic>> fetchStockCategoryHierarchy()=> _apiService.get(InventoryApiConfig.stockCategoryTreeAPI);

  Future<Map<String, dynamic>> createStockCategory(
    CreateStockCategoryRequest request,
  ) =>
      _apiService.post(
        InventoryApiConfig.createStockCategoryAPI,
        data: request.toJson(),
      );

  Future<Map<String, dynamic>> deleteStockCategory(int id) =>
      _apiService.delete(ApiConfig.stockCategoryEndpoint(id));
}
