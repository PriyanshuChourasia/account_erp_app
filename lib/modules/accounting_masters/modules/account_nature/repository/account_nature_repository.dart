import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/account_nature.dart';
import '../models/create_account_nature_request.dart';
import '../services/account_nature_service.dart';

/// Orchestrates account nature data: calls [AccountNatureService], unwraps the
/// [ResponseModelWrapper] envelope and throws [AppException] on failure.
class AccountNatureRepository {
  AccountNatureRepository(this._accountNatureService);

  final AccountNatureService _accountNatureService;

  Future<List<AccountNature>> fetchAccountNatures() async {
    final json = await _accountNatureService.fetchAccountNatures();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not load account natures.',
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult
        .whereType<Map<String, dynamic>>()
        .map(AccountNature.fromJson)
        .toList();
  }

  Future<void> createAccountNature(CreateAccountNatureRequest request) async {
    final json = await _accountNatureService.createAccountNature(request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create account nature.',
        code: wrapper.code,
      );
    }
  }

  Future<void> deleteAccountNature(int id) async {
    final json = await _accountNatureService.deleteAccountNature(id);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not delete account nature.',
        code: wrapper.code,
      );
    }
  }
}
