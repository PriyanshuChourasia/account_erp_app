import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// A company used by organisational masters.
///
/// Mirrors the backend `CompanyDTO` record. [demo] serves as placeholder data
/// until the backend is reachable.
class Company {
  const Company({
    required this.id,
    required this.name,
    this.code,
    this.alias,
    this.description,
    this.isActive = true,
    this.icon = Icons.business_rounded,
    this.color = AppColors.primary,
  });

  final int id;
  final String name;

  /// Short company code, e.g. `ACME`.
  final String? code;
  final String? alias;
  final String? description;
  final bool isActive;
  final IconData icon;
  final Color color;

  factory Company.fromJson(Map<String, dynamic> json) => Company(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    code: json['code'] as String?,
    alias: json['alias'] as String?,
    description: json['description'] as String?,
    isActive: json['isActive'] == true,
  );

  static const List<Company> demo = [
    Company(
      id: 1,
      name: 'Acme Traders',
      code: 'ACME',
      description: 'Trading and distribution business',
      icon: Icons.business_rounded,
      color: Color(0xFF0D9488),
    ),
    Company(
      id: 2,
      name: 'Sunrise Industries',
      code: 'SUNRISE',
      description: 'Manufacturing and exports',
      icon: Icons.factory_rounded,
      color: Color(0xFF1D4ED8),
    ),
    Company(
      id: 3,
      name: 'Blue Orchid Retail',
      code: 'BOR',
      description: 'Retail chain',
      icon: Icons.storefront_rounded,
      color: Color(0xFF7C3AED),
    ),
  ];
}
