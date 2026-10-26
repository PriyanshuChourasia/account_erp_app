import 'package:account_erp_app/modules/payroll_masters/configs/payroll_api_config.dart';

import '../../../../../network/api_service.dart';
import '../models/create_employee_request.dart';

/// Raw HTTP calls for employees. No parsing, no state.
class EmployeeService {
  EmployeeService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchEmployees() =>
      _apiService.get(PayrollApiConfig.employeeAPI);

  Future<Map<String, dynamic>> createEmployee(CreateEmployeeRequest request) =>
      _apiService.post(
        PayrollApiConfig.createEmployeeAPI,
        data: request.toJson(),
      );

  Future<Map<String, dynamic>> deleteEmployee(String id) =>
      _apiService.delete(PayrollApiConfig.employeeEndpoint(id));
}
