import 'package:flutter/material.dart';

import '../../../../../../config/theme/app_theme.dart';

/// An employee group used to classify employees, e.g. `Permanent`, `Contract`.
///
/// Mirrors the backend `EmployeeGroupDTO` record. [demo] serves as placeholder
/// data until the backend is reachable.
class EmployeeGroup {
  const EmployeeGroup({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.isActive = true,
    this.icon = Icons.groups_rounded,
    this.color = AppColors.primary,
  });

  final String id;
  final String name;
  final String? code;
  final String? description;
  final bool isActive;
  final IconData icon;
  final Color color;

  factory EmployeeGroup.fromJson(Map<String, dynamic> json) => EmployeeGroup(
    id: json['id']?.toString() ?? '',
    name: json['name'] as String? ?? '',
    code: json['code'] as String?,
    description: json['description'] as String?,
    isActive: json['active'] != false,
  );

  static const List<EmployeeGroup> demo = [
    EmployeeGroup(
      id: '1',
      name: 'Permanent',
      code: 'PERM',
      description: 'Regular full-time employees',
      icon: Icons.groups_rounded,
      color: Color(0xFF059669),
    ),
    EmployeeGroup(
      id: '2',
      name: 'Contract',
      code: 'CONT',
      description: 'Contract-based employees',
      icon: Icons.description_rounded,
      color: Color(0xFFD97706),
    ),
    EmployeeGroup(
      id: '3',
      name: 'Intern',
      code: 'INT',
      description: 'Internship employees',
      icon: Icons.person_add_rounded,
      color: Color(0xFF1D4ED8),
    ),
  ];
}
