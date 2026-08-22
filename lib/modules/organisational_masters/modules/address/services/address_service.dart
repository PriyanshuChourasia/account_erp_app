import 'package:account_erp_app/modules/organisational_masters/configs/organisational_api_config.dart';

import '../../../../../network/api_service.dart';
import '../models/create_address_request.dart';

/// Raw HTTP calls for addresses. No parsing, no state.
class AddressService {
  AddressService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchAddresses() =>
      _apiService.get(OrganisationalApiConfig.addressAPI);

  Future<Map<String, dynamic>> createAddress(CreateAddressRequest request) =>
      _apiService.post(
        OrganisationalApiConfig.createAddressAPI,
        data: request.toJson(),
      );

  Future<Map<String, dynamic>> deleteAddress(String id) =>
      _apiService.delete(OrganisationalApiConfig.addressEndpoint(id));
}
