import 'package:account_erp_app/modules/utility/configs/utility_api_config.dart';

import '../../../../../network/api_service.dart';
import '../models/create_blood_group_request.dart';

/// Raw HTTP calls for blood groups. No parsing, no state.
class BloodGroupService {
  BloodGroupService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchBloodGroups() =>
      _apiService.get(UtilityApiConfig.bloodGroupAPI);

  Future<Map<String, dynamic>> createBloodGroup(CreateBloodGroupRequest request) =>
      _apiService.post(
        UtilityApiConfig.createBloodGroupAPI,
        data: request.toJson(),
      );

  Future<Map<String, dynamic>> deleteBloodGroup(int id) =>
      _apiService.delete(UtilityApiConfig.bloodGroupEndpoint(id));
}
