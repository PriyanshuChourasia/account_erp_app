import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/application_module.dart';
import '../models/create_application_module_request.dart';
import '../services/application_module_service.dart';

/// Orchestrates application module data: calls [ApplicationModuleService],
/// unwraps the [ResponseModelWrapper] envelope and throws [AppException] on
/// failure.
class ApplicationModuleRepository {
  ApplicationModuleRepository(this._applicationModuleService);

  final ApplicationModuleService _applicationModuleService;

  Future<List<ApplicationModule>> fetchApplicationModules() async {
    final json = await _applicationModuleService.fetchApplicationModules();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not load application modules.',
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult
        .whereType<Map<String, dynamic>>()
        .map(ApplicationModule.fromJson)
        .toList();
  }

  Future<void> createApplicationModule(
    CreateApplicationModuleRequest request,
  ) async {
    final json = await _applicationModuleService.createApplicationModule(
      request,
    );
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create application module.',
        code: wrapper.code,
      );
    }
  }

  Future<void> deleteApplicationModule(String id) async {
    final json = await _applicationModuleService.deleteApplicationModule(id);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not delete application module.',
        code: wrapper.code,
      );
    }
  }
}
