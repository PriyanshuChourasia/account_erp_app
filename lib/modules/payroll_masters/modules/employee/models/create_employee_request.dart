/// Request payload for creating an employee.
///
/// Mirrors the backend `CreateEmployeeDTO` record. Nullable fields are
/// omitted from JSON so the backend's `@NotBlank` validation only applies to
/// the required ones.
class CreateEmployeeRequest {
  const CreateEmployeeRequest({
    required this.name,
    this.employeeCode,
    this.email,
    this.phone,
    this.designation,
    this.department,
    this.dateOfJoining,
    this.basicSalary,
  });

  final String name;
  final String? employeeCode;
  final String? email;
  final String? phone;
  final String? designation;
  final String? department;
  final String? dateOfJoining;
  final num? basicSalary;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (employeeCode != null) 'employeeCode': employeeCode,
    if (email != null) 'email': email,
    if (phone != null) 'phone': phone,
    if (designation != null) 'designation': designation,
    if (department != null) 'department': department,
    if (dateOfJoining != null) 'dateOfJoining': dateOfJoining,
    if (basicSalary != null) 'basicSalary': basicSalary,
  };
}
