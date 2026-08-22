import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/address.dart';
import '../models/create_address_request.dart';
import '../services/address_service.dart';

/// Orchestrates address data: calls [AddressService], unwraps the
/// [ResponseModelWrapper] envelope and throws [AppException] on failure.
class AddressRepository {
  AddressRepository(this._addressService);

  final AddressService _addressService;

  Future<List<Address>> fetchAddresses() async {
    final json = await _addressService.fetchAddresses();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not load addresses.',
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult
        .whereType<Map<String, dynamic>>()
        .map(Address.fromJson)
        .toList();
  }

  Future<void> createAddress(CreateAddressRequest request) async {
    final json = await _addressService.createAddress(request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create address.',
        code: wrapper.code,
      );
    }
  }

  Future<void> deleteAddress(String id) async {
    final json = await _addressService.deleteAddress(id);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not delete address.',
        code: wrapper.code,
      );
    }
  }
}
