import 'package:account_erp_app/modules/payroll_masters/configs/payroll_api_config.dart';

import '../../../../../network/api_service.dart';
import '../models/create_employee_category_request.dart';

/// Raw HTTP calls for employee categories. No parsing, no state.
class EmployeeCategoryService {
  EmployeeCategoryService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchEmployeeCategories() =>
      _apiService.get(PayrollApiConfig.employeeCategoryListAPI);

  Future<Map<String, dynamic>> createEmployeeCategory(
    CreateEmployeeCategoryRequest request,
  ) => _apiService.post(
    PayrollApiConfig.createEmployeeCategoryAPI,
    data: request.toJson(),
  );

  Future<Map<String, dynamic>> updateEmployeeCategory(
    String id,
    CreateEmployeeCategoryRequest request,
  ) => _apiService.put(
    PayrollApiConfig.employeeCategoryEndpoint(id),
    data: request.toJson(),
  );

  Future<Map<String, dynamic>> deleteEmployeeCategory(String id) =>
      _apiService.delete(PayrollApiConfig.employeeCategoryEndpoint(id));
}
