import '../../../configs/developer_api_config.dart';
import '../../../../../network/api_service.dart';
import '../models/create_application_feature_request.dart';

/// Raw HTTP calls for application features. No parsing, no state.
class ApplicationFeatureService {
  ApplicationFeatureService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchApplicationFeatures() =>
      _apiService.get(DeveloperApiConfig.applicationFeatureAPI);

  Future<Map<String, dynamic>> createApplicationFeature(
    CreateApplicationFeatureRequest request,
  ) => _apiService.post(
    DeveloperApiConfig.createApplicationFeatureAPI,
    data: request.toJson(),
  );

  Future<Map<String, dynamic>> deleteApplicationFeature(String id) =>
      _apiService.delete(DeveloperApiConfig.applicationFeatureEndpoint(id));
}
