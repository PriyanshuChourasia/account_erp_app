import '../../../configs/developer_api_config.dart';
import '../../../../../network/api_service.dart';
import '../models/create_application_module_request.dart';

/// Raw HTTP calls for application modules. No parsing, no state.
class ApplicationModuleService {
  ApplicationModuleService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchApplicationModules() =>
      _apiService.get(DeveloperApiConfig.applicationModuleAPI);

  Future<Map<String, dynamic>> createApplicationModule(
    CreateApplicationModuleRequest request,
  ) => _apiService.post(
    DeveloperApiConfig.createApplicationModuleAPI,
    data: request.toJson(),
  );

  Future<Map<String, dynamic>> deleteApplicationModule(String id) =>
      _apiService.delete(DeveloperApiConfig.applicationModuleEndpoint(id));
}
