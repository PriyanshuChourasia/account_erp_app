import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/bank_type.dart';
import '../models/create_bank_type_request.dart';
import '../services/bank_type_service.dart';

/// Orchestrates bank type data: calls [BankTypeService], unwraps the
/// [ResponseModelWrapper] envelope and throws [AppException] on failure.
class BankTypeRepository {
  BankTypeRepository(this._bankTypeService);

  final BankTypeService _bankTypeService;

  Future<List<BankType>> fetchBankTypes() async {
    final json = await _bankTypeService.fetchBankTypes();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not load bank types.',
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult.whereType<Map<String, dynamic>>().map(BankType.fromJson).toList();
  }

  Future<void> createBankType(CreateBankTypeRequest request) async {
    final json = await _bankTypeService.createBankType(request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create bank type.',
        code: wrapper.code,
      );
    }
  }

  Future<void> deleteBankType(int id) async {
    final json = await _bankTypeService.deleteBankType(id);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not delete bank type.',
        code: wrapper.code,
      );
    }
  }
}