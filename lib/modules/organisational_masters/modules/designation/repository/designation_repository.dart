import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/designation.dart';
import '../models/create_designation_request.dart';
import '../services/designation_service.dart';

/// Orchestrates designation data: calls [DesignationService], unwraps the
/// [ResponseModelWrapper] envelope and throws [AppException] on failure.
class DesignationRepository {
  DesignationRepository(this._designationService);

  final DesignationService _designationService;

  Future<List<Designation>> fetchDesignations() async {
    final json = await _designationService.fetchDesignations();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not load designations.',
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult
        .whereType<Map<String, dynamic>>()
        .map(Designation.fromJson)
        .toList();
  }

  Future<void> createDesignation(CreateDesignationRequest request) async {
    final json = await _designationService.createDesignation(request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create designation.',
        code: wrapper.code,
      );
    }
  }

  Future<void> updateDesignation(
    String id,
    CreateDesignationRequest request,
  ) async {
    final json = await _designationService.updateDesignation(id, request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not update designation.',
        code: wrapper.code,
      );
    }
  }

  Future<void> deleteDesignation(String id) async {
    final json = await _designationService.deleteDesignation(id);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not delete designation.',
        code: wrapper.code,
      );
    }
  }
}
