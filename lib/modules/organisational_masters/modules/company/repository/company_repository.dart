import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/company.dart';
import '../models/create_company_request.dart';
import '../services/company_service.dart';

/// Orchestrates company data: calls [CompanyService], unwraps the
/// [ResponseModelWrapper] envelope and throws [AppException] on failure.
class CompanyRepository {
  CompanyRepository(this._companyService);

  final CompanyService _companyService;

  Future<List<Company>> fetchCompanies() async {
    final json = await _companyService.fetchCompanies();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not load companies.',
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult
        .whereType<Map<String, dynamic>>()
        .map(Company.fromJson)
        .toList();
  }

  Future<void> createCompany(CreateCompanyRequest request) async {
    final json = await _companyService.createCompany(request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create company.',
        code: wrapper.code,
      );
    }
  }

  Future<void> deleteCompany(int id) async {
    final json = await _companyService.deleteCompany(id);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not delete company.',
        code: wrapper.code,
      );
    }
  }
}
