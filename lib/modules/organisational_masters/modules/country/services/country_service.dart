import 'package:account_erp_app/modules/organisational_masters/configs/organisational_api_config.dart';

import '../../../../../network/api_service.dart';
import '../models/create_country_request.dart';

/// Raw HTTP calls for countries. No parsing, no state.
class CountryService {
  CountryService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchCountries() =>
      _apiService.get(OrganisationalApiConfig.countryAPI);

  Future<Map<String, dynamic>> createCountry(CreateCountryRequest request) =>
      _apiService.post(
        OrganisationalApiConfig.createCountryAPI,
        data: request.toJson(),
      );

  Future<Map<String, dynamic>> deleteCountry(String id) =>
      _apiService.delete(OrganisationalApiConfig.countryEndpoint(id));
}
