import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/country.dart';
import '../models/create_country_request.dart';
import '../services/country_service.dart';

/// Orchestrates country data: calls [CountryService], unwraps the
/// [ResponseModelWrapper] envelope and throws [AppException] on failure.
class CountryRepository {
  CountryRepository(this._countryService);

  final CountryService _countryService;

  Future<List<Country>> fetchCountries() async {
    final json = await _countryService.fetchCountries();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not load countries.',
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult
        .whereType<Map<String, dynamic>>()
        .map(Country.fromJson)
        .toList();
  }

  Future<void> createCountry(CreateCountryRequest request) async {
    final json = await _countryService.createCountry(request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create country.',
        code: wrapper.code,
      );
    }
  }

  Future<void> deleteCountry(int id) async {
    final json = await _countryService.deleteCountry(id);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not delete country.',
        code: wrapper.code,
      );
    }
  }
}
