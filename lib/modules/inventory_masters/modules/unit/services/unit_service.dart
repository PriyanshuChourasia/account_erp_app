import 'package:account_erp_app/modules/inventory_masters/configs/inventory_api_config.dart';

import '../../../../../network/api_service.dart';
import '../models/create_stock_unit_request.dart';

/// Raw HTTP calls for units. No parsing, no state.
class UnitService {
  UnitService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchUnits() =>
      _apiService.get(InventoryApiConfig.unitListAPI);

  Future<Map<String, dynamic>> createUnit(CreateStockUnitRequest request) =>
      _apiService.post(
        InventoryApiConfig.createUnitAPI,
        data: request.toJson(),
      );

  Future<Map<String, dynamic>> deleteUnit(String id) =>
      _apiService.delete(InventoryApiConfig.unitEndpoint(id));
}
