import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/bank_branch.dart';
import '../models/create_bank_branch_request.dart';
import '../services/bank_branch_service.dart';

/// Orchestrates bank branch data: calls [BankBranchService], unwraps the
/// [ResponseModelWrapper] envelope and throws [AppException] on failure.
class BankBranchRepository {
  BankBranchRepository(this._bankBranchService);

  final BankBranchService _bankBranchService;

  Future<List<BankBranch>> fetchBankBranches() async {
    final json = await _bankBranchService.fetchBankBranches();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not load bank branches.',
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult
        .whereType<Map<String, dynamic>>()
        .map(BankBranch.fromJson)
        .toList();
  }

  Future<void> createBankBranch(CreateBankBranchRequest request) async {
    final json = await _bankBranchService.createBankBranch(request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create bank branch.',
        code: wrapper.code,
      );
    }
  }

  Future<void> deleteBankBranch(int id) async {
    final json = await _bankBranchService.deleteBankBranch(id);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not delete bank branch.',
        code: wrapper.code,
      );
    }
  }
}