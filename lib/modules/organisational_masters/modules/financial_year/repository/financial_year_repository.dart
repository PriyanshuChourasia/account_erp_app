import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/create_financial_year_request.dart';
import '../models/financial_year.dart';
import '../services/financial_year_service.dart';

/// Orchestrates financial year data: calls [FinancialYearService], unwraps
/// the [ResponseModelWrapper] envelope and throws [AppException] on failure.
class FinancialYearRepository {
  FinancialYearRepository(this._service);

  final FinancialYearService _service;

  Future<List<FinancialYear>> fetchFinancialYears() async {
    final json = await _service.fetchFinancialYears();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not load financial years.',
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult
        .whereType<Map<String, dynamic>>()
        .map(FinancialYear.fromJson)
        .toList();
  }

  Future<void> createFinancialYear(CreateFinancialYearRequest request) async {
    final json = await _service.createFinancialYear(request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create financial year.',
        code: wrapper.code,
      );
    }
  }

  Future<void> updateCurrentFinancialYear(int id, bool current) async {
    final json = await _service.updateCurrentFinancialYear(id, current);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not update financial year.',
        code: wrapper.code,
      );
    }
  }
}
