import '../../../../../network/api_service.dart';
import '../../../configs/organisational_api_config.dart';
import '../models/create_designation_request.dart';

/// Raw HTTP calls for designations. No parsing, no state.
class DesignationService {
  DesignationService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchDesignations() =>
      _apiService.get(OrganisationalApiConfig.designationAPI);

  Future<Map<String, dynamic>> createDesignation(
    CreateDesignationRequest request,
  ) => _apiService.post(
    OrganisationalApiConfig.createDesignationAPI,
    data: request.toJson(),
  );

  Future<Map<String, dynamic>> updateDesignation(
    String id,
    CreateDesignationRequest request,
  ) => _apiService.put(
    OrganisationalApiConfig.designationEndpoint(id),
    data: request.toJson(),
  );

  Future<Map<String, dynamic>> deleteDesignation(String id) =>
      _apiService.delete(OrganisationalApiConfig.designationEndpoint(id));
}
