import 'package:account_erp_app/modules/accounting_masters/configs/accounting_api_config.dart';

import '../../../../../network/api_service.dart';
import '../models/create_account_ledger_request.dart';

/// Raw HTTP calls for account ledgers. No parsing, no state.
class AccountLedgerService {
  AccountLedgerService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchAccountLedgers() =>
      _apiService.get(AccountingApiConfig.accountLedgerAPI);

  Future<Map<String, dynamic>> createAccountLedger(
          CreateAccountLedgerRequest request) =>
      _apiService.post(
        AccountingApiConfig.createAccountLedgerAPI,
        data: request.toJson(),
      );

  Future<Map<String, dynamic>> deleteAccountLedger(int id) =>
      _apiService.delete(AccountingApiConfig.accountLedgerEndpoint(id));
}
