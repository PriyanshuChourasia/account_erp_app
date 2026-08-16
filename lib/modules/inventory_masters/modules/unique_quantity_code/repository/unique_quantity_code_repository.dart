import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/create_unique_quantity_code_request.dart';
import '../models/update_unique_quantity_code_request.dart';
import '../models/unique_quantity_code.dart';
import '../services/unique_quantity_code_service.dart';

/// Orchestrates UQC data: calls [UniqueQuantityCodeService], unwraps the
/// [ResponseModelWrapper] envelope and throws [AppException] on failure.
class UniqueQuantityCodeRepository {
  UniqueQuantityCodeRepository(this._uqcService);

  final UniqueQuantityCodeService _uqcService;

  Future<List<UniqueQuantityCode>> fetchUniqueQuantityCodes() async {
    final json = await _uqcService.fetchUniqueQuantityCodes();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not load UQCs.',
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult
        .whereType<Map<String, dynamic>>()
        .map(UniqueQuantityCode.fromJson)
        .toList();
  }

  Future<void> createUniqueQuantityCode(
    CreateUniqueQuantityCodeRequest request,
  ) async {
    final json = await _uqcService.createUniqueQuantityCode(request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create UQC.',
        code: wrapper.code,
      );
    }
  }

  Future<void> updateUniqueQuantityCode(
    UpdateUniqueQuantityCodeRequest request,
  ) async {
    final json = await _uqcService.updateUniqueQuantityCode(
      request.id,
      request,
    );
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not update UQC.',
        code: wrapper.code,
      );
    }
  }
}
