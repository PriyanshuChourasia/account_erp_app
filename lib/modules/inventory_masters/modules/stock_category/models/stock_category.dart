import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// A stock category used to classify inventory items.
///
/// Mirrors the backend `StockCategoryDTO` record. [demo] serves as placeholder
/// data until the backend is reachable.
class StockCategory {
  const StockCategory({
    required this.id,
    required this.name,
    this.code,
    this.alias,
    this.description,
    this.isActive = true,
    this.children,
    this.icon = Icons.category_rounded,
    this.color = AppColors.primary,
  });

  final int id;
  final String name;
  final String? code;
  final String? alias;
  final String? description;
  final bool isActive;
  final List<StockCategory>? children;
  final IconData icon;
  final Color color;

  factory StockCategory.fromJson(Map<String, dynamic> json) => StockCategory(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        code: json['code'] as String?,
        alias: json['alias'] as String?,
        description: json['description'] as String?,
        isActive: json['isActive'] == true,
        children: (json['children'] as List<dynamic>?)
            ?.map((child) => StockCategory.fromJson(child as Map<String, dynamic>))
            .toList(),
      );

  static const List<StockCategory> demo = [
    StockCategory(
      id: 1,
      name: 'Electronics',
      code: 'ELEC',
      description: 'Electronic goods and accessories',
      icon: Icons.devices_rounded,
      color: Color(0xFF1D4ED8),
    ),
    StockCategory(
      id: 2,
      name: 'Furniture',
      code: 'FURN',
      alias: 'Furnishings',
      description: 'Office and home furniture',
      icon: Icons.chair_rounded,
      color: Color(0xFF059669),
    ),
    StockCategory(
      id: 3,
      name: 'Consumables',
      code: 'CONS',
      isActive: false,
      icon: Icons.recycling_rounded,
      color: Color(0xFFD97706),
    ),
    StockCategory(
      id: 4,
      name: 'Stationery',
      code: 'STAT',
      description: 'Paper, pens and office supplies',
      icon: Icons.edit_rounded,
      color: Color(0xFF7C3AED),
    ),
  ];
}
