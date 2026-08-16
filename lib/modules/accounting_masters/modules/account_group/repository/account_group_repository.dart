import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/account_group.dart';
import '../models/create_account_group_request.dart';
import '../models/update_account_group_request.dart';
import '../services/account_group_service.dart';

/// Orchestrates accounting group data: calls [AccountGroupService], unwraps
/// the [ResponseModelWrapper] envelope and throws [AppException] on failure.
class AccountGroupRepository {
  AccountGroupRepository(this._accountingGroupService);

  final AccountGroupService _accountingGroupService;

  Future<List<AccountGroup>> fetchAccountGroups() async {
    final json = await _accountingGroupService.fetchAccountGroups();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not load accounting groups.',
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult
        .whereType<Map<String, dynamic>>()
        .map(AccountGroup.fromJson)
        .toList();
  }

  Future<void> createAccountGroup(CreateAccountGroupRequest request) async {
    final json = await _accountingGroupService.createAccountGroup(request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create accounting group.',
        code: wrapper.code,
      );
    }
  }

  Future<void> updateAccountGroup(UpdateAccountGroupRequest request) async {
    final json = await _accountingGroupService.updateAccountGroup(
      request.id,
      request,
    );
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not update accounting group.',
        code: wrapper.code,
      );
    }
  }

  Future<void> deleteAccountGroup(int id) async {
    final json = await _accountingGroupService.deleteAccountGroup(id);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not delete accounting group.',
        code: wrapper.code,
      );
    }
  }
}
