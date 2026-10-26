import 'package:flutter/material.dart';

import '../../../../../../config/theme/app_theme.dart';

/// An employee category used to classify employees, e.g. `Teaching`,
/// `Non-Teaching`.
///
/// Mirrors the backend `EmployeeCategoryDTO` record.
class EmployeeCategory {
  const EmployeeCategory({
    required this.id,
    required this.name,
    this.alias,
    this.description,
    this.allocateRevenueItem = false,
    this.allocateNonRevenueItem = false,
    this.isActive = true,
    this.icon = Icons.category_rounded,
    this.color = AppColors.primary,
  });

  final String id;
  final String name;
  final String? alias;
  final String? description;
  final bool allocateRevenueItem;
  final bool allocateNonRevenueItem;
  final bool isActive;
  final IconData icon;
  final Color color;

  factory EmployeeCategory.fromJson(Map<String, dynamic> json) =>
      EmployeeCategory(
        id: json['id']?.toString() ?? '',
        name: json['name'] as String? ?? '',
        alias: json['alias'] as String?,
        description: json['description'] as String?,
        allocateRevenueItem: json['allocateRevenueItem'] == true,
        allocateNonRevenueItem: json['allocateNonRevenueItem'] == true,
        isActive: json['active'] != false,
      );
}
