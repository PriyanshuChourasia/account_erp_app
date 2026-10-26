import 'package:account_erp_app/modules/payroll_masters/configs/payroll_api_config.dart';

import '../../../../../network/api_service.dart';
import '../models/create_employee_group_request.dart';

/// Raw HTTP calls for employee groups. No parsing, no state.
class EmployeeGroupService {
  EmployeeGroupService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchEmployeeGroups() =>
      _apiService.get(PayrollApiConfig.employeeGroupListAPI);

  Future<Map<String, dynamic>> createEmployeeGroup(
    CreateEmployeeGroupRequest request,
  ) => _apiService.post(
    PayrollApiConfig.createEmployeeGroupAPI,
    data: request.toJson(),
  );

  Future<Map<String, dynamic>> updateEmployeeGroup(
    String id,
    CreateEmployeeGroupRequest request,
  ) => _apiService.put(
    PayrollApiConfig.employeeGroupEndpoint(id),
    data: request.toJson(),
  );

  Future<Map<String, dynamic>> deleteEmployeeGroup(String id) =>
      _apiService.delete(PayrollApiConfig.employeeGroupEndpoint(id));
}
