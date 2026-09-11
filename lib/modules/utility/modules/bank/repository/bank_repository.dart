import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/bank.dart';
import '../models/create_bank_request.dart';
import '../services/bank_service.dart';

/// Orchestrates bank data: calls [BankService], unwraps the
/// [ResponseModelWrapper] envelope and throws [AppException] on failure.
class BankRepository {
  BankRepository(this._bankService);

  final BankService _bankService;

  Future<List<Bank>> fetchBanks() async {
    final json = await _bankService.fetchBanks();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not load banks.',
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult.whereType<Map<String, dynamic>>().map(Bank.fromJson).toList();
  }

  Future<void> createBank(CreateBankRequest request) async {
    final json = await _bankService.createBank(request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create bank.',
        code: wrapper.code,
      );
    }
  }

  Future<void> deleteBank(int id) async {
    final json = await _bankService.deleteBank(id);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not delete bank.',
        code: wrapper.code,
      );
    }
  }
}