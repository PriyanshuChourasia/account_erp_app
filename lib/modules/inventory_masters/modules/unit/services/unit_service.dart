import 'package:account_erp_app/modules/inventory_masters/configs/inventory_api_config.dart';

import '../../../../../config/api_config.dart';
import '../../../../../network/api_service.dart';
import '../models/create_unit_request.dart';

/// Raw HTTP calls for units. No parsing, no state.
class UnitService {
  UnitService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchUnits() =>
      _apiService.get(InventoryApiConfig.createUnitAPI);

  Future<Map<String, dynamic>> createUnit(CreateUnitRequest request) =>
      _apiService.post(ApiConfig.unitCreateEndpoint, data: request.toJson());

  Future<Map<String, dynamic>> deleteUnit(int id) =>
      _apiService.delete(ApiConfig.unitEndpoint(id));
}
