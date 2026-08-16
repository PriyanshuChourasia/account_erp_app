import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/create_uqc_request.dart';
import '../models/update_uqc_request.dart';
import '../models/uqc.dart';
import '../services/uqc_service.dart';

/// Orchestrates UQC data: calls [UqcService], unwraps the
/// [ResponseModelWrapper] envelope and throws [AppException] on failure.
class UqcRepository {
  UqcRepository(this._uqcService);

  final UqcService _uqcService;

  Future<List<Uqc>> fetchUqcs() async {
    final json = await _uqcService.fetchUqcs();
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
        .map(Uqc.fromJson)
        .toList();
  }

  Future<void> createUqc(CreateUqcRequest request) async {
    final json = await _uqcService.createUqc(request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create UQC.',
        code: wrapper.code,
      );
    }
  }

  Future<void> updateUqc(UpdateUqcRequest request) async {
    final json = await _uqcService.updateUqc(request.id, request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not update UQC.',
        code: wrapper.code,
      );
    }
  }
}
