import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/account_ledger.dart';
import '../models/create_account_ledger_request.dart';
import '../services/account_ledger_service.dart';

/// Orchestrates account ledger data: calls [AccountLedgerService], unwraps the
/// [ResponseModelWrapper] envelope and throws [AppException] on failure.
class AccountLedgerRepository {
  AccountLedgerRepository(this._accountLedgerService);

  final AccountLedgerService _accountLedgerService;

  Future<List<AccountLedger>> fetchAccountLedgers() async {
    final json = await _accountLedgerService.fetchAccountLedgers();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not load account ledgers.',
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult
        .whereType<Map<String, dynamic>>()
        .map(AccountLedger.fromJson)
        .toList();
  }

  Future<void> createAccountLedger(CreateAccountLedgerRequest request) async {
    final json = await _accountLedgerService.createAccountLedger(request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create account ledger.',
        code: wrapper.code,
      );
    }
  }

  Future<void> deleteAccountLedger(int id) async {
    final json = await _accountLedgerService.deleteAccountLedger(id);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not delete account ledger.',
        code: wrapper.code,
      );
    }
  }
}
