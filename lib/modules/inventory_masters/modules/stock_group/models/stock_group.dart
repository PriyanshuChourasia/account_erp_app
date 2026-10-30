import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// A stock group used to classify inventory items.
///
/// Mirrors the backend `StockGroupDTO` record.
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

  final String id;
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
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    code: json['code'] as String?,
    alias: json['alias'] as String?,
    description: json['description'] as String?,
    isActive: json['isActive'] == true,
    shouldAddQuantities: json['shouldAddQuantities'] == true,
    setAlterGstDetail: json['setAlterGstDetail'] == true,
  );
}
