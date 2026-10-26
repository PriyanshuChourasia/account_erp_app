import '../../../../../network/api_service.dart';
import '../../../configs/utility_api_config.dart';
import '../models/create_gender_request.dart';

/// Raw HTTP calls for genders. No parsing, no state.
class GenderService {
  GenderService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchGenders() =>
      _apiService.get(UtilityApiConfig.genderListAPI);

  Future<Map<String, dynamic>> createGender(CreateGenderRequest request) =>
      _apiService.post(
        UtilityApiConfig.createGenderAPI,
        data: request.toJson(),
      );

  Future<Map<String, dynamic>> updateGender(
    String id,
    CreateGenderRequest request,
  ) => _apiService.put(
    UtilityApiConfig.genderEndpoint(id),
    data: request.toJson(),
  );

  Future<Map<String, dynamic>> deleteGender(String id) =>
      _apiService.delete(UtilityApiConfig.genderEndpoint(id));
}
