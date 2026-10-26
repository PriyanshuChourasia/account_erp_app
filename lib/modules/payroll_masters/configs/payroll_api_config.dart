/// API endpoints for the payroll masters module.
class PayrollApiConfig {
  PayrollApiConfig._();

  /// employees
  static const String employeeAPI = "/employees";
  static const String createEmployeeAPI = "$employeeAPI/create";
  static String employeeEndpoint(String id) => "$employeeAPI/$id";

  /// employee groups
  static const String employeeGroupAPI = "/employee_groups";
  static const String employeeGroupListAPI = "$employeeGroupAPI/list";
  static const String createEmployeeGroupAPI = "$employeeGroupAPI/create";
  static String employeeGroupEndpoint(String id) => "$employeeGroupAPI/$id";

  /// employee categories
  static const String employeeCategoryAPI = "/employee_categories";
  static const String employeeCategoryListAPI = "$employeeCategoryAPI/list";
  static const String createEmployeeCategoryAPI = "$employeeCategoryAPI/create";
  static String employeeCategoryEndpoint(String id) =>
      "$employeeCategoryAPI/$id";
}
