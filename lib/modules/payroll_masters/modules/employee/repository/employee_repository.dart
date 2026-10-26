import '../../../../../core/app_exception.dart';
import '../../../../../data/models/response_model_wrapper.dart';
import '../models/create_employee_request.dart';
import '../models/employee.dart';
import '../services/employee_service.dart';

/// Orchestrates employee data: calls [EmployeeService], unwraps the
/// [ResponseModelWrapper] envelope and throws [AppException] on failure.
class EmployeeRepository {
  EmployeeRepository(this._employeeService);

  final EmployeeService _employeeService;

  Future<List<Employee>> fetchEmployees() async {
    final json = await _employeeService.fetchEmployees();
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not load employees.',
        code: wrapper.code,
      );
    }
    final rawResult = wrapper.data?.result;
    if (rawResult is! List) return const [];
    return rawResult
        .whereType<Map<String, dynamic>>()
        .map(Employee.fromJson)
        .toList();
  }

  Future<void> createEmployee(CreateEmployeeRequest request) async {
    final json = await _employeeService.createEmployee(request);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not create employee.',
        code: wrapper.code,
      );
    }
  }

  Future<void> deleteEmployee(String id) async {
    final json = await _employeeService.deleteEmployee(id);
    final wrapper = ResponseModelWrapper<dynamic>.fromJson(json);
    if (!wrapper.success) {
      throw AppException(
        wrapper.message ?? 'Could not delete employee.',
        code: wrapper.code,
      );
    }
  }
}
