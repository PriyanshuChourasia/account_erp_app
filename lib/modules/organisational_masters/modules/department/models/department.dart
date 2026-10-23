import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';


/// A department within the organisation.
///
/// Mirrors the backend `DepartmentDTO` record. [demo] serves as placeholder
/// data until the backend is reachable.
class Department {
  const Department({
    required this.id,
    required this.name,
    this.code,
    this.parentId,
    this.description,
    this.isActive = true,
    this.icon = Icons.business_rounded,
    this.color = AppColors.primary,
  });

  final String id;
  final String name;
  final String? code;

  /// Parent department id — departments can form a hierarchy.
  final String? parentId;
  final String? description;
  final bool isActive;
  final IconData icon;
  final Color color;

  factory Department.fromJson(Map<String, dynamic> json) => Department(
    id: json['id']?.toString() ?? '',
    name: json['name'] as String? ?? '',
    code: json['code'] as String?,
    parentId: json['parentId']?.toString(),
    description: json['description'] as String?,
    // The backend sends `active`; absent means active.
    isActive: json['active'] != false,
  );

  static List<Department> get demo => _demoList;

  static const List<Department> _demoList = [
    Department(
      id: '1',
      name: 'Accounts',
      code: 'ACC',
      description: 'Accounts and finance',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF0D9488),
    ),
    Department(
      id: '2',
      name: 'Sales',
      code: 'SLS',
      description: 'Sales and marketing',
      icon: Icons.campaign_rounded,
      color: Color(0xFF059669),
    ),
    Department(
      id: '3',
      name: 'HR',
      code: 'HR',
      description: 'Human resources',
      icon: Icons.people_rounded,
      color: Color(0xFF7C3AED),
    ),
    Department(
      id: '4',
      name: 'Engineering',
      code: 'ENG',
      icon: Icons.engineering_rounded,
      color: Color(0xFFD97706),
    ),
  ];

}
