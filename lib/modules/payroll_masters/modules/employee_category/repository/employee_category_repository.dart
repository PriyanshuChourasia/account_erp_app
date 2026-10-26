import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/create_employee_category_request.dart';
import '../models/employee_category.dart';
import '../services/employee_category_service.dart';

/// Orchestrates employee category data: calls [EmployeeCategoryService], unwraps
/// the [ResponseModelWrapper] envelope and throws [AppException] on failure.
class EmployeeCategoryRepository {
  EmployeeCategoryRepository(this._employeeCategoryService);

  final EmployeeCategoryService _employeeCategoryService;

  Future<List<EmployeeCategory>> fetchEmployeeCategories() async {
    final json = await _employeeCategoryService.fetchEmployeeCategories();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not load employee categories.',
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult
        .whereType<Map<String, dynamic>>()
        .map(EmployeeCategory.fromJson)
        .toList();
  }

  Future<void> createEmployeeCategory(
    CreateEmployeeCategoryRequest request,
  ) async {
    final json = await _employeeCategoryService.createEmployeeCategory(request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create employee category.',
        code: wrapper.code,
      );
    }
  }

  Future<void> updateEmployeeCategory(
    String id,
    CreateEmployeeCategoryRequest request,
  ) async {
    final json = await _employeeCategoryService.updateEmployeeCategory(
      id,
      request,
    );
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not update employee category.',
        code: wrapper.code,
      );
    }
  }

  Future<void> deleteEmployeeCategory(String id) async {
    final json = await _employeeCategoryService.deleteEmployeeCategory(id);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not delete employee category.',
        code: wrapper.code,
      );
    }
  }
}
