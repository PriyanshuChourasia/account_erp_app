import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/department.dart';
import '../models/create_department_request.dart';
import '../services/department_service.dart';

/// Orchestrates department data: calls [DepartmentService], unwraps the
/// [ResponseModelWrapper] envelope and throws [AppException] on failure.
class DepartmentRepository {
  DepartmentRepository(this._departmentService);

  final DepartmentService _departmentService;

  Future<List<Department>> fetchDepartments() async {
    final json = await _departmentService.fetchDepartments();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not load departments.',
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult
        .whereType<Map<String, dynamic>>()
        .map(Department.fromJson)
        .toList();
  }

  Future<void> createDepartment(CreateDepartmentRequest request) async {
    final json = await _departmentService.createDepartment(request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create department.',
        code: wrapper.code,
      );
    }
  }

  Future<void> updateDepartment(
    String id,
    CreateDepartmentRequest request,
  ) async {
    final json = await _departmentService.updateDepartment(id, request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not update department.',
        code: wrapper.code,
      );
    }
  }

  Future<void> deleteDepartment(String id) async {
    final json = await _departmentService.deleteDepartment(id);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not delete department.',
        code: wrapper.code,
      );
    }
  }
}

