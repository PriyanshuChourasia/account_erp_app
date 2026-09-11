import 'package:account_erp_app/modules/utility/configs/utility_api_config.dart';

import '../../../../../network/api_service.dart';
import '../models/create_bank_branch_request.dart';

/// Raw HTTP calls for bank branches. No parsing, no state.
class BankBranchService {
  BankBranchService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchBankBranches() =>
      _apiService.get(UtilityApiConfig.bankBranchAPI);

  Future<Map<String, dynamic>> createBankBranch(
    CreateBankBranchRequest request,
  ) => _apiService.post(
    UtilityApiConfig.createBankBranchAPI,
    data: request.toJson(),
  );

  Future<Map<String, dynamic>> deleteBankBranch(int id) =>
      _apiService.delete(UtilityApiConfig.bankBranchEndpoint(id));
}