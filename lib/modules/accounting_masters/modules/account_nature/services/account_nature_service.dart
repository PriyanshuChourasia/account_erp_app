import 'package:account_erp_app/modules/accounting_masters/configs/accounting_api_config.dart';

import '../../../../../network/api_service.dart';
import '../models/create_account_nature_request.dart';

/// Raw HTTP calls for account natures. No parsing, no state.
class AccountNatureService {
  AccountNatureService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchAccountNatures() =>
      _apiService.get(AccountingApiConfig.accountNatureAPI);

  Future<Map<String, dynamic>> createAccountNature(
          CreateAccountNatureRequest request) =>
      _apiService.post(
        AccountingApiConfig.createAccountNatureAPI,
        data: request.toJson(),
      );

  Future<Map<String, dynamic>> deleteAccountNature(int id) =>
      _apiService.delete(AccountingApiConfig.accountNatureEndpoint(id));
}
