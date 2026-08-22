import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/create_state_request.dart';
import '../models/state_master.dart';
import '../services/state_service.dart';

/// Orchestrates state data: calls [StateService], unwraps the
/// [ResponseModelWrapper] envelope and throws [AppException] on failure.
class StateRepository {
  StateRepository(this._stateService);

  final StateService _stateService;

  Future<List<StateMaster>> fetchStates() async {
    final json = await _stateService.fetchStates();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not load states.',
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult
        .whereType<Map<String, dynamic>>()
        .map(StateMaster.fromJson)
        .toList();
  }

  Future<void> createState(CreateStateRequest request) async {
    final json = await _stateService.createState(request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create state.',
        code: wrapper.code,
      );
    }
  }

  Future<void> deleteState(String id) async {
    final json = await _stateService.deleteState(id);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not delete state.',
        code: wrapper.code,
      );
    }
  }
}
