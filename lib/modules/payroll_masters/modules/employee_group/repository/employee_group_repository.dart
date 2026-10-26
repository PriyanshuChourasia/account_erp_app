import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/create_employee_group_request.dart';
import '../models/employee_group.dart';
import '../services/employee_group_service.dart';

/// Orchestrates employee group data: calls [EmployeeGroupService], unwraps
/// the [ResponseModelWrapper] envelope and throws [AppException] on failure.
class EmployeeGroupRepository {
  EmployeeGroupRepository(this._employeeGroupService);

  final EmployeeGroupService _employeeGroupService;

  Future<List<EmployeeGroup>> fetchEmployeeGroups() async {
    final json = await _employeeGroupService.fetchEmployeeGroups();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not load employee groups.',
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult
        .whereType<Map<String, dynamic>>()
        .map(EmployeeGroup.fromJson)
        .toList();
  }

  Future<void> createEmployeeGroup(CreateEmployeeGroupRequest request) async {
    final json = await _employeeGroupService.createEmployeeGroup(request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create employee group.',
        code: wrapper.code,
      );
    }
  }

  Future<void> updateEmployeeGroup(
    String id,
    CreateEmployeeGroupRequest request,
  ) async {
    final json = await _employeeGroupService.updateEmployeeGroup(id, request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not update employee group.',
        code: wrapper.code,
      );
    }
  }

  Future<void> deleteEmployeeGroup(String id) async {
    final json = await _employeeGroupService.deleteEmployeeGroup(id);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not delete employee group.',
        code: wrapper.code,
      );
    }
  }
}
