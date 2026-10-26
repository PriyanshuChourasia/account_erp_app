import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/create_gender_request.dart';
import '../models/gender.dart';
import '../services/gender_service.dart';

/// Orchestrates gender data: calls [GenderService], unwraps the
/// [ResponseModelWrapper] envelope and throws [AppException] on failure.
class GenderRepository {
  GenderRepository(this._genderService);

  final GenderService _genderService;

  Future<List<Gender>> fetchGenders() async {
    final json = await _genderService.fetchGenders();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not load genders.',
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult
        .whereType<Map<String, dynamic>>()
        .map(Gender.fromJson)
        .toList();
  }

  Future<void> createGender(CreateGenderRequest request) async {
    final json = await _genderService.createGender(request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create gender.',
        code: wrapper.code,
      );
    }
  }

  Future<void> updateGender(String id, CreateGenderRequest request) async {
    final json = await _genderService.updateGender(id, request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not update gender.',
        code: wrapper.code,
      );
    }
  }

  Future<void> deleteGender(String id) async {
    final json = await _genderService.deleteGender(id);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not delete gender.',
        code: wrapper.code,
      );
    }
  }
}
