import 'package:account_erp_app/modules/organisational_masters/configs/organisational_api_config.dart';

import '../../../../../network/api_service.dart';
import '../models/create_financial_year_request.dart';

/// Raw HTTP calls for financial years. No parsing, no state.
class FinancialYearService {
  FinancialYearService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchFinancialYears() =>
      _apiService.get(OrganisationalApiConfig.financialYearAPI);

  Future<Map<String, dynamic>> createFinancialYear(
    CreateFinancialYearRequest request,
  ) => _apiService.post(
    OrganisationalApiConfig.createFinancialYearAPI,
    data: request.toJson(),
  );

  Future<Map<String, dynamic>> updateCurrentFinancialYear(
    String id,
    bool current,
  ) => _apiService.get(
    OrganisationalApiConfig.updateFinancialYearCurrentAPI,
    queryParameters: {'id': id, 'current': current},
  );
}
