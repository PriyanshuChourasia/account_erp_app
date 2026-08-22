import 'package:account_erp_app/modules/organisational_masters/configs/organisational_api_config.dart';

import '../../../../../network/api_service.dart';
import '../models/create_state_request.dart';

/// Raw HTTP calls for states. No parsing, no state.
class StateService {
  StateService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchStates() =>
      _apiService.get(OrganisationalApiConfig.stateAPI);

  Future<Map<String, dynamic>> createState(CreateStateRequest request) =>
      _apiService.post(
        OrganisationalApiConfig.createStateAPI,
        data: request.toJson(),
      );

  Future<Map<String, dynamic>> deleteState(String id) =>
      _apiService.delete(OrganisationalApiConfig.stateEndpoint(id));
}
