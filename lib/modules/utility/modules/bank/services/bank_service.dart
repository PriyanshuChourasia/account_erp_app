import 'package:account_erp_app/modules/utility/configs/utility_api_config.dart';

import '../../../../../network/api_service.dart';
import '../models/create_bank_request.dart';

/// Raw HTTP calls for banks. No parsing, no state.
class BankService {
  BankService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchBanks() =>
      _apiService.get(UtilityApiConfig.bankAPI);

  Future<Map<String, dynamic>> createBank(CreateBankRequest request) =>
      _apiService.post(UtilityApiConfig.createBankAPI, data: request.toJson());

  Future<Map<String, dynamic>> deleteBank(int id) =>
      _apiService.delete(UtilityApiConfig.bankEndpoint(id));
}