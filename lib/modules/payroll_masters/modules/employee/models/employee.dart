import 'package:flutter/material.dart';

import '../../../../../../config/theme/app_theme.dart';

/// An employee, e.g. `John Doe`.
///
/// Mirrors the backend `EmployeeDTO` record. [demo] serves as placeholder
/// data until the backend is reachable.
class Employee {
  const Employee({
    required this.id,
    required this.name,
    this.employeeCode,
    this.email,
    this.phone,
    this.designation,
    this.department,
    this.dateOfJoining,
    this.basicSalary,
    this.isActive = true,
    this.icon = Icons.person_rounded,
    this.color = AppColors.primary,
  });

  final String id;
  final String name;
  final String? employeeCode;
  final String? email;
  final String? phone;
  final String? designation;
  final String? department;
  final String? dateOfJoining;
  final num? basicSalary;
  final bool isActive;
  final IconData icon;
  final Color color;

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
    id: json['id']?.toString() ?? '',
    name: json['name'] as String? ?? '',
    employeeCode: json['employeeCode'] as String?,
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    designation: json['designation'] as String?,
    department: json['department'] as String?,
    dateOfJoining: json['dateOfJoining'] as String?,
    basicSalary: (json['basicSalary'] as num?),
    isActive: json['isActive'] == true,
  );

  static const List<Employee> demo = [
    Employee(
      id: '1',
      name: 'John Doe',
      employeeCode: 'EMP001',
      email: 'john.doe@example.com',
      phone: '+1 234 567 8900',
      designation: 'Software Engineer',
      department: 'Engineering',
      dateOfJoining: '2024-01-15',
      basicSalary: 75000,
      icon: Icons.person_rounded,
      color: Color(0xFF1D4ED8),
    ),
    Employee(
      id: '2',
      name: 'Jane Smith',
      employeeCode: 'EMP002',
      email: 'jane.smith@example.com',
      phone: '+1 234 567 8901',
      designation: 'Accountant',
      department: 'Finance',
      dateOfJoining: '2023-06-10',
      basicSalary: 62000,
      icon: Icons.person_rounded,
      color: Color(0xFF059669),
    ),
    Employee(
      id: '3',
      name: 'Robert Brown',
      employeeCode: 'EMP003',
      email: 'robert.brown@example.com',
      phone: '+1 234 567 8902',
      designation: 'HR Manager',
      department: 'Human Resources',
      dateOfJoining: '2022-11-01',
      basicSalary: 68000,
      icon: Icons.person_rounded,
      color: Color(0xFF7C3AED),
    ),
  ];
}
