import 'package:account_erp_app/modules/accounting_masters/configs/accounting_api_config.dart';

import '../../../../../network/api_service.dart';
import '../models/create_account_group_request.dart';

/// Raw HTTP calls for accounting groups. No parsing, no state.
class AccountGroupService {
  AccountGroupService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchAccountGroups() =>
      _apiService.get(AccountingApiConfig.accountGroupAPI);

  Future<Map<String, dynamic>> createAccountGroup(
          CreateAccountGroupRequest request) =>
      _apiService.post(
        AccountingApiConfig.createAccountGroupAPI,
        data: request.toJson(),
      );

  Future<Map<String, dynamic>> deleteAccountGroup(int id) =>
      _apiService.delete(AccountingApiConfig.accountGroupEndpoint(id));
}
