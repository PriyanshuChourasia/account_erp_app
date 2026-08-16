import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// A stock item — an individual inventory product tracked under a stock
/// group, stock category and unit of measurement.
///
/// This is a lean scaffold: only the core identity and classification fields
/// are modelled for now (no GST/HSN, opening balances, godowns or batches
/// yet). Mirrors the backend `StockItemDTO` record. [demo] serves as
/// placeholder data until the backend is reachable.
class StockItem {
  const StockItem({
    required this.id,
    required this.name,
    this.alias,
    this.code,
    this.description,
    this.stockGroupId,
    this.stockCategoryId,
    this.unitId,
    this.isActive = true,
    this.icon = Icons.inventory_2_rounded,
    this.color = AppColors.primary,
  });

  final int id;
  final String name;
  final String? alias;
  final String? code;
  final String? description;

  /// The stock group this item is classified under.
  final int? stockGroupId;

  /// The stock category this item is classified under.
  final int? stockCategoryId;

  /// The unit of measurement this item is quantified in.
  final int? unitId;
  final bool isActive;
  final IconData icon;
  final Color color;

  factory StockItem.fromJson(Map<String, dynamic> json) => StockItem(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    alias: json['alias'] as String?,
    code: json['code'] as String?,
    description: json['description'] as String?,
    stockGroupId: (json['stockGroupId'] as num?)?.toInt(),
    stockCategoryId: (json['stockCategoryId'] as num?)?.toInt(),
    unitId: (json['unitId'] as num?)?.toInt(),
    isActive: json['isActive'] == true,
  );

  static const List<StockItem> demo = [
    StockItem(
      id: 1,
      name: 'A4 Copier Paper',
      code: 'PAP-A4',
      description: '80 GSM, ream of 500 sheets',
      stockGroupId: 4,
      stockCategoryId: 4,
      unitId: 5,
      icon: Icons.description_rounded,
      color: Color(0xFF1D4ED8),
    ),
    StockItem(
      id: 2,
      name: 'Wireless Mouse',
      alias: 'Mouse',
      code: 'ELEC-MS1',
      description: '2.4GHz wireless optical mouse',
      stockGroupId: 2,
      stockCategoryId: 1,
      unitId: 1,
      icon: Icons.mouse_rounded,
      color: Color(0xFF059669),
    ),
    StockItem(
      id: 3,
      name: 'Steel Sheet 2mm',
      code: 'RAW-SS2',
      description: 'Cold-rolled steel sheet, 2mm thickness',
      stockGroupId: 3,
      unitId: 3,
      icon: Icons.square_foot_rounded,
      color: Color(0xFFD97706),
    ),
    StockItem(
      id: 4,
      name: 'Office Chair',
      code: 'FURN-CH1',
      stockGroupId: 4,
      stockCategoryId: 2,
      unitId: 1,
      isActive: false,
      icon: Icons.chair_rounded,
      color: Color(0xFF7C3AED),
    ),
  ];
}
