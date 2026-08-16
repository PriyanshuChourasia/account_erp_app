import 'package:account_erp_app/modules/accounting_masters/configs/accounting_api_config.dart';

import '../../../../../network/api_service.dart';
import '../models/create_voucher_type_request.dart';

/// Raw HTTP calls for voucher types. No parsing, no state.
class VoucherTypeService {
  VoucherTypeService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchVoucherTypes() =>
      _apiService.get(AccountingApiConfig.voucherTypeAPI);

  Future<Map<String, dynamic>> createVoucherType(
    CreateVoucherTypeRequest request,
  ) => _apiService.post(
    AccountingApiConfig.createVoucherTypeAPI,
    data: request.toJson(),
  );

  Future<Map<String, dynamic>> deleteVoucherType(int id) =>
      _apiService.delete(AccountingApiConfig.voucherTypeEndpoint(id));
}
