import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../models/address.dart';
import '../models/create_address_request.dart';
import '../repository/address_repository.dart';

/// Holds all address UI state.
///
/// Screens only ever interact with this class — never with the repository.
class AddressViewModel extends ChangeNotifier {
  AddressViewModel(this._repository);

  final AddressRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<Address> _addresses = const [];
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<Address> get addresses => _addresses;

  /// Addresses filtered by the current search query.
  List<Address> get filteredAddresses {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _addresses;
    return _addresses
        .where(
          (address) =>
              address.line1.toLowerCase().contains(query) ||
              (address.city?.toLowerCase().contains(query) ?? false) ||
              (address.area?.toLowerCase().contains(query) ?? false) ||
              address.pinCode.toLowerCase().contains(query) ||
              address.addressType.toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> loadAddresses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _addresses = await _repository.fetchAddresses();
    } on AppException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<bool> addAddress(CreateAddressRequest request) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.createAddress(request);
      await loadAddresses();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> deleteAddress(String id) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteAddress(id);
      await loadAddresses();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }
}
