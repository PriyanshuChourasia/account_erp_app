import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// A blood group, e.g. `A+`, `O-`.
///
/// Mirrors the backend `BloodGroupDTO` record. [demo] serves as placeholder
/// data until the backend is reachable.
class BloodGroup {
  const BloodGroup({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.isActive = true,
    this.icon = Icons.bloodtype,
    this.color = AppColors.primary,
  });

  final int id;

  /// Display name, e.g. `A+`.
  final String name;

  /// Short code, e.g. `A_POSITIVE`.
  final String? code;
  final String? description;
  final bool isActive;
  final IconData icon;
  final Color color;

  factory BloodGroup.fromJson(Map<String, dynamic> json) => BloodGroup(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    code: json['code'] as String?,
    description: json['description'] as String?,
    isActive: json['isActive'] == true,
  );

  static const List<BloodGroup> demo = [
    BloodGroup(
      id: 1,
      name: 'A+',
      code: 'A_POSITIVE',
      description: 'A positive',
      icon: Icons.bloodtype,
      color: Color(0xFF1D4ED8),
    ),
    BloodGroup(
      id: 2,
      name: 'A-',
      code: 'A_NEGATIVE',
      description: 'A negative',
      icon: Icons.bloodtype,
      color: Color(0xFF059669),
    ),
    BloodGroup(
      id: 3,
      name: 'B+',
      code: 'B_POSITIVE',
      description: 'B positive',
      icon: Icons.bloodtype,
      color: Color(0xFF7C3AED),
    ),
    BloodGroup(
      id: 4,
      name: 'B-',
      code: 'B_NEGATIVE',
      description: 'B negative',
      icon: Icons.bloodtype,
      color: Color(0xFFD97706),
    ),
    BloodGroup(
      id: 5,
      name: 'O+',
      code: 'O_POSITIVE',
      description: 'O positive',
      icon: Icons.bloodtype,
      color: Color(0xFFDC2626),
    ),
    BloodGroup(
      id: 6,
      name: 'O-',
      code: 'O_NEGATIVE',
      description: 'O negative',
      icon: Icons.bloodtype,
      color: Color(0xFF0891B2),
    ),
    BloodGroup(
      id: 7,
      name: 'AB+',
      code: 'AB_POSITIVE',
      description: 'AB positive',
      icon: Icons.bloodtype,
      color: Color(0xFF7C2D12),
    ),
    BloodGroup(
      id: 8,
      name: 'AB-',
      code: 'AB_NEGATIVE',
      description: 'AB negative',
      icon: Icons.bloodtype,
      color: Color(0xFF6B21A8),
    ),
  ];
}
