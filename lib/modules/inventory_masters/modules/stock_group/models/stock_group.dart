import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// A stock group used to classify inventory items.
///
/// Mirrors the backend `StockGroupDTO` record. [demo] serves as placeholder
/// data until the backend is reachable.
class StockGroup {
  const StockGroup({
    required this.id,
    required this.name,
    this.code,
    this.alias,
    this.description,
    this.isActive = true,
    this.shouldAddQuantities = false,
    this.setAlterGstDetail = false,
    this.icon = Icons.folder_rounded,
    this.color = AppColors.primary,
  });

  final int id;
  final String name;
  final String? code;
  final String? alias;
  final String? description;
  final bool isActive;
  final bool shouldAddQuantities;
  final bool setAlterGstDetail;
  final IconData icon;
  final Color color;

  factory StockGroup.fromJson(Map<String, dynamic> json) => StockGroup(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    code: json['code'] as String?,
    alias: json['alias'] as String?,
    description: json['description'] as String?,
    isActive: json['isActive'] == true,
    shouldAddQuantities: json['shouldAddQuantities'] == true,
    setAlterGstDetail: json['setAlterGstDetail'] == true,
  );

  static const List<StockGroup> demo = [
    StockGroup(
      id: 1,
      name: 'Primary',
      code: 'PRIM',
      description: 'Root group for the stock tree',
      isActive: false,
      icon: Icons.folder_special_rounded,
      color: Color(0xFF1D4ED8),
    ),
    StockGroup(
      id: 2,
      name: 'Trading Goods',
      code: 'TRAD',
      alias: 'Trading',
      description: 'Goods bought and sold',
      shouldAddQuantities: true,
      setAlterGstDetail: true,
      icon: Icons.shopping_cart_rounded,
      color: Color(0xFF059669),
    ),
    StockGroup(
      id: 3,
      name: 'Raw Materials',
      code: 'RAW',
      description: 'Inputs used in production',
      shouldAddQuantities: true,
      icon: Icons.precision_manufacturing_rounded,
      color: Color(0xFFD97706),
    ),
    StockGroup(
      id: 4,
      name: 'Finished Goods',
      code: 'FIN',
      description: 'Ready-for-sale products',
      shouldAddQuantities: true,
      setAlterGstDetail: true,
      icon: Icons.checkroom_rounded,
      color: Color(0xFF7C3AED),
    ),
    StockGroup(
      id: 5,
      name: 'Consumables',
      code: 'CONS',
      alias: 'Consumable Stores',
      isActive: false,
      icon: Icons.recycling_rounded,
      color: Color(0xFF3B82F6),
    ),
  ];
}
