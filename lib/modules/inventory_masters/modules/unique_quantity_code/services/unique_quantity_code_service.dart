import 'package:account_erp_app/modules/inventory_masters/configs/inventory_api_config.dart';

import '../../../../../network/api_service.dart';
import '../models/create_unique_quantity_code_request.dart';
import '../models/update_unique_quantity_code_request.dart';

/// Raw HTTP calls for UQCs. No parsing, no state.
class UniqueQuantityCodeService {
  UniqueQuantityCodeService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchUniqueQuantityCodes() =>
      _apiService.get(InventoryApiConfig.uniqueQuantityCodeAPI);

  Future<Map<String, dynamic>> createUniqueQuantityCode(
    CreateUniqueQuantityCodeRequest request,
  ) => _apiService.post(
    InventoryApiConfig.createUniqueQuantityCodeAPI,
    data: request.toJson(),
  );

  Future<Map<String, dynamic>> updateUniqueQuantityCode(
    int id,
    UpdateUniqueQuantityCodeRequest request,
  ) => _apiService.put(
    InventoryApiConfig.uniqueQuantityCodeEndpoint(id),
    data: request.toJson(),
  );
}
