import 'package:flutter/foundation.dart';

import '../../../../../core/app_exception.dart';
import '../models/create_voucher_type_request.dart';
import '../models/voucher_type.dart';
import '../repository/voucher_type_repository.dart';

/// Holds all voucher type UI state.
///
/// Screens only ever interact with this class — never with the repository.
class VoucherTypeViewModel extends ChangeNotifier {
  VoucherTypeViewModel(this._repository);

  final VoucherTypeRepository _repository;

  bool _isLoading = false;
  String? _error;
  List<VoucherType> _voucherTypes = const [];
  String _query = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  List<VoucherType> get voucherTypes => _voucherTypes;

  /// Voucher types filtered by the current search query.
  List<VoucherType> get filteredVoucherTypes {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _voucherTypes;
    return _voucherTypes
        .where(
          (voucherType) =>
              voucherType.name.toLowerCase().contains(query) ||
              voucherType.id.toString().contains(query) ||
              (voucherType.code?.toLowerCase().contains(query) ?? false) ||
              (voucherType.description?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  Future<void> loadVoucherTypes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _voucherTypes = await _repository.fetchVoucherTypes();
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

  Future<bool> addVoucherType(CreateVoucherTypeRequest request) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.createVoucherType(request);
      await loadVoucherTypes();
      return true;
    } on AppException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Please try again.';
      return false;
    }
  }

  Future<bool> deleteVoucherType(int id) async {
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteVoucherType(id);
      await loadVoucherTypes();
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
