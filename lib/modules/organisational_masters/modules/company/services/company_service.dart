import 'package:account_erp_app/modules/organisational_masters/configs/organisational_api_config.dart';

import '../../../../../network/api_service.dart';
import '../models/create_company_request.dart';

/// Raw HTTP calls for companies. No parsing, no state.
class CompanyService {
  CompanyService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchCompanies() =>
      _apiService.get(OrganisationalApiConfig.companyAPI);

  Future<Map<String, dynamic>> createCompany(CreateCompanyRequest request) =>
      _apiService.post(
        OrganisationalApiConfig.createCompanyAPI,
        data: request.toJson(),
      );

  Future<Map<String, dynamic>> deleteCompany(int id) =>
      _apiService.delete(OrganisationalApiConfig.companyEndpoint(id));
}
