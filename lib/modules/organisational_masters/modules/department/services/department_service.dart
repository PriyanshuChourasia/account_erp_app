import '../../../../../network/api_service.dart';
import '../../../configs/organisational_api_config.dart';
import '../models/create_department_request.dart';

/// Raw HTTP calls for departments. No parsing, no state.
class DepartmentService {
  DepartmentService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> fetchDepartments() =>
      _apiService.get(OrganisationalApiConfig.departmentAPI);

  Future<Map<String, dynamic>> createDepartment(CreateDepartmentRequest request) =>
      _apiService.post(
        OrganisationalApiConfig.createDepartmentAPI,
        data: request.toJson(),
      );

  Future<Map<String, dynamic>> updateDepartment(
    String id,
    CreateDepartmentRequest request,
  ) => _apiService.put(
    OrganisationalApiConfig.departmentEndpoint(id),
    data: request.toJson(),
  );

  Future<Map<String, dynamic>> deleteDepartment(String id) =>
      _apiService.delete(OrganisationalApiConfig.departmentEndpoint(id));
}

