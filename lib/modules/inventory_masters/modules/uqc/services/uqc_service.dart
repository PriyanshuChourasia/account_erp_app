import 'package:account_erp_app/modules/inventory_masters/configs/inventory_api_config.dart';

import '../../../../../network/api_service.dart';
import '../models/create_uqc_request.dart';
import '../models/update_uqc_request.dart';

/// Raw HTTP calls for UQCs. No parsing, no state.
class UqcService {
  UqcService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchUqcs() =>
      _apiService.get(InventoryApiConfig.uniqueQuantityCodeAPI);

  Future<Map<String, dynamic>> createUqc(CreateUqcRequest request) =>
      _apiService.post(InventoryApiConfig.createUniqueQuantityCodeAPI, data: request.toJson());

  Future<Map<String, dynamic>> updateUqc(int id, UpdateUqcRequest request) =>
      _apiService.put(
        InventoryApiConfig.uniqueQuantityCodeEndpoint(id),
        data: request.toJson(),
      );
}
