import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/blood_group.dart';
import '../models/create_blood_group_request.dart';
import '../services/blood_group_service.dart';

/// Orchestrates blood group data: calls [BloodGroupService], unwraps the
/// [ResponseModelWrapper] envelope and throws [AppException] on failure.
class BloodGroupRepository {
  BloodGroupRepository(this._bloodGroupService);

  final BloodGroupService _bloodGroupService;

  Future<List<BloodGroup>> fetchBloodGroups() async {
    final json = await _bloodGroupService.fetchBloodGroups();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not load blood groups.',
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult
        .whereType<Map<String, dynamic>>()
        .map(BloodGroup.fromJson)
        .toList();
  }

  Future<void> createBloodGroup(CreateBloodGroupRequest request) async {
    final json = await _bloodGroupService.createBloodGroup(request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create blood group.',
        code: wrapper.code,
      );
    }
  }

  Future<void> deleteBloodGroup(int id) async {
    final json = await _bloodGroupService.deleteBloodGroup(id);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not delete blood group.',
        code: wrapper.code,
      );
    }
  }
}
