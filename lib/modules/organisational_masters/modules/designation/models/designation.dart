import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// A designation within the organisation.
///
/// Mirrors the backend `DesignationDTO` record. [demo] serves as placeholder
/// data until the backend is reachable.
class Designation {
  const Designation({
    required this.id,
    required this.name,
    this.code,
    this.parentId,
    this.description,
    this.isActive = true,
    this.icon = Icons.work_rounded,
    this.color = AppColors.primary,
  });

  final String id;
  final String name;
  final String? code;

  /// Parent designation id — designations can form a hierarchy
  /// (e.g. `Accountant` reporting to `Senior Accountant`).
  final String? parentId;
  final String? description;
  final bool isActive;
  final IconData icon;
  final Color color;

  factory Designation.fromJson(Map<String, dynamic> json) => Designation(
    id: json['id']?.toString() ?? '',
    name: json['name'] as String? ?? '',
    code: json['code'] as String?,
    parentId: json['parentId']?.toString(),
    description: json['description'] as String?,
    // The backend sends `active`; absent means active.
    isActive: json['active'] != false,
  );

  static List<Designation> get demo => _demoList;

  static const List<Designation> _demoList = [
    Designation(
      id: '1',
      name: 'Accountant',
      code: 'ACCOUNTANT',
      description: 'Junior accounting role',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF0D9488),
    ),
    Designation(
      id: '2',
      name: 'Senior Accountant',
      code: 'SR_ACC',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF059669),
    ),
    Designation(
      id: '3',
      name: 'HR Executive',
      code: 'HR_EXEC',
      description: 'Human resources executive',
      icon: Icons.people_rounded,
      color: Color(0xFF7C3AED),
    ),
    Designation(
      id: '4',
      name: 'Software Engineer',
      code: 'SWE',
      icon: Icons.engineering_rounded,
      color: Color(0xFFD97706),
    ),
  ];
}
