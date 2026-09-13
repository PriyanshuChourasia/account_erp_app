import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/application_feature.dart';
import '../models/create_application_feature_request.dart';
import '../services/application_feature_service.dart';

/// Orchestrates application feature data: calls [ApplicationFeatureService],
/// unwraps the [ResponseModelWrapper] envelope and throws [AppException] on
/// failure.
class ApplicationFeatureRepository {
  ApplicationFeatureRepository(this._applicationFeatureService);

  final ApplicationFeatureService _applicationFeatureService;

  Future<List<ApplicationFeature>> fetchApplicationFeatures() async {
    final json = await _applicationFeatureService.fetchApplicationFeatures();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not load application features.',
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult
        .whereType<Map<String, dynamic>>()
        .map(ApplicationFeature.fromJson)
        .toList();
  }

  Future<void> createApplicationFeature(
    CreateApplicationFeatureRequest request,
  ) async {
    final json = await _applicationFeatureService.createApplicationFeature(
      request,
    );
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create application feature.',
        code: wrapper.code,
      );
    }
  }

  Future<void> deleteApplicationFeature(String id) async {
    final json = await _applicationFeatureService.deleteApplicationFeature(
      id,
    );
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not delete application feature.',
        code: wrapper.code,
      );
    }
  }
}
