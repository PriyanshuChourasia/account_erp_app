import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/create_unit_request.dart';
import '../models/unit.dart';
import '../services/unit_service.dart';

/// Orchestrates unit data: calls [UnitService], unwraps the
/// [ResponseModelWrapper] envelope and throws [AppException] on failure.
class UnitRepository {
  UnitRepository(this._unitService);

  final UnitService _unitService;

  Future<List<Unit>> fetchUnits() async {
    final json = await _unitService.fetchUnits();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not load units.',
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult
        .whereType<Map<String, dynamic>>()
        .map(Unit.fromJson)
        .toList();
  }

  Future<void> createUnit(CreateUnitRequest request) async {
    final json = await _unitService.createUnit(request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create unit.',
        code: wrapper.code,
      );
    }
  }

  Future<void> deleteUnit(int id) async {
    final json = await _unitService.deleteUnit(id);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not delete unit.',
        code: wrapper.code,
      );
    }
  }
}
