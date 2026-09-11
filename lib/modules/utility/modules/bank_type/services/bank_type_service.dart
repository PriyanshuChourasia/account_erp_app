import 'package:account_erp_app/modules/utility/configs/utility_api_config.dart';

import '../../../../../network/api_service.dart';
import '../models/create_bank_type_request.dart';

/// Raw HTTP calls for bank types. No parsing, no state.
class BankTypeService {
  BankTypeService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchBankTypes() =>
      _apiService.get(UtilityApiConfig.bankTypeAPI);

  Future<Map<String, dynamic>> createBankType(CreateBankTypeRequest request) =>
      _apiService.post(
        UtilityApiConfig.createBankTypeAPI,
        data: request.toJson(),
      );

  Future<Map<String, dynamic>> deleteBankType(int id) =>
      _apiService.delete(UtilityApiConfig.bankTypeEndpoint(id));
}