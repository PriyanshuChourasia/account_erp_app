import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/create_voucher_type_request.dart';
import '../models/voucher_type.dart';
import '../services/voucher_type_service.dart';

/// Orchestrates voucher type data: calls [VoucherTypeService], unwraps the
/// [ResponseModelWrapper] envelope and throws [AppException] on failure.
class VoucherTypeRepository {
  VoucherTypeRepository(this._service);

  final VoucherTypeService _service;

  Future<List<VoucherType>> fetchVoucherTypes() async {
    final json = await _service.fetchVoucherTypes();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not load voucher types.',
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult
        .whereType<Map<String, dynamic>>()
        .map(VoucherType.fromJson)
        .toList();
  }

  Future<void> createVoucherType(CreateVoucherTypeRequest request) async {
    final json = await _service.createVoucherType(request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create voucher type.',
        code: wrapper.code,
      );
    }
  }

  Future<void> deleteVoucherType(int id) async {
    final json = await _service.deleteVoucherType(id);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not delete voucher type.',
        code: wrapper.code,
      );
    }
  }
}
