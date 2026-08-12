import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// A unit of measurement used to quantify inventory items.
///
/// Mirrors the backend `UnitDTO` record. [demo] serves as placeholder data
/// until the backend is reachable.
class Unit {
  const Unit({
    required this.id,
    required this.name,
    this.alias,
    this.description,
    this.code,
    this.unitType,
    this.operator,
    this.baseUnit1Id,
    this.baseUnit2Id,
    this.conversionFactor,
    this.decimalPlaces,
    this.isActive = true,
    this.icon = Icons.square_foot_rounded,
    this.color = AppColors.primary,
  });

  final int id;
  final String name;
  final String? alias;
  final String? description;
  final String? code;

  /// e.g. `simple` or `compound`.
  final String? unitType;

  /// Arithmetic operator linking [baseUnit1Id] to [baseUnit2Id].
  final String? operator;
  final int? baseUnit1Id;
  final int? baseUnit2Id;

  /// Factor used when converting to/from the base unit(s).
  final double? conversionFactor;
  final int? decimalPlaces;
  final bool isActive;
  final IconData icon;
  final Color color;

  factory Unit.fromJson(Map<String, dynamic> json) => Unit(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        alias: json['alias'] as String?,
        description: json['description'] as String?,
        code: json['code'] as String?,
        unitType: json['unitType'] as String?,
        operator: json['operator'] as String?,
        baseUnit1Id: (json['baseUnit1Id'] as num?)?.toInt(),
        baseUnit2Id: (json['baseUnit2Id'] as num?)?.toInt(),
        conversionFactor: (json['conversionFactor'] as num?)?.toDouble(),
        decimalPlaces: (json['decimalPlaces'] as num?)?.toInt(),
        isActive: json['isActive'] == true,
      );

  static const List<Unit> demo = [
    Unit(
      id: 1,
      name: 'Piece',
      code: 'PCS',
      description: 'Individual unit of an item',
      icon: Icons.crop_square_rounded,
      color: Color(0xFF1D4ED8),
    ),
    Unit(
      id: 2,
      name: 'Kilogram',
      code: 'KG',
      description: 'Unit of mass equal to 1000 grams',
      icon: Icons.balance_rounded,
      color: Color(0xFF059669),
    ),
    Unit(
      id: 3,
      name: 'Meter',
      code: 'MTR',
      description: 'Unit of length',
      icon: Icons.straighten_rounded,
      color: Color(0xFFD97706),
    ),
    Unit(
      id: 4,
      name: 'Liter',
      code: 'LTR',
      description: 'Unit of volume',
      icon: Icons.local_drink_rounded,
      color: Color(0xFF7C3AED),
    ),
    Unit(
      id: 5,
      name: 'Box',
      code: 'BOX',
      description: 'Standard shipping container',
      icon: Icons.inventory_2_rounded,
      color: Color(0xFF3B82F6),
    ),
    Unit(
      id: 6,
      name: 'Dozen',
      code: 'DZN',
      isActive: false,
      icon: Icons.grid_view_rounded,
      color: Color(0xFF0D9488),
    ),
  ];
}
