import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';
import 'stock_unit_type.dart';

/// A unit of measurement used to quantify inventory items.
///
/// Mirrors the backend `UnitDTO` record. [demo] serves as placeholder data
/// until the backend is reachable.
class Unit {
  const Unit({
    required this.id,
    required this.name,
    this.alias,
    this.symbol,
    this.unitType,
    this.uqcId,
    this.primaryUnitId,
    this.secondaryUnitId,
    this.conversionFactor,
    this.decimalPlaces,
    this.isActive = true,
    this.icon = Icons.square_foot_rounded,
    this.color = AppColors.primary,
  });

  final String id;
  final String name;
  final String? alias;
  final String? symbol;

  /// Whether the unit is [StockUnitType.simple] or [StockUnitType.compound].
  final StockUnitType? unitType;

  /// UQC (Unit Quantity Code) this unit maps to, e.g. `NOS`, `KGS`.
  final String? uqcId;

  /// Primary base unit of a compound unit, e.g. `Piece`.
  final String? primaryUnitId;

  /// Secondary base unit of a compound unit, e.g. `Dozen`.
  final String? secondaryUnitId;

  /// Factor used when converting to/from the base unit(s).
  final double? conversionFactor;
  final int? decimalPlaces;
  final bool isActive;
  final IconData icon;
  final Color color;

  factory Unit.fromJson(Map<String, dynamic> json) => Unit(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    alias: json['alias'] as String?,
    symbol: json['symbol'] as String?,
    unitType: StockUnitType.fromWire(json['unitType'] as String?),
    uqcId: json['uqcId'] as String?,
    primaryUnitId: json['primaryUnitId'] as String?,
    secondaryUnitId: json['secondaryUnitId'] as String?,
    conversionFactor: (json['conversionFactor'] as num?)?.toDouble(),
    decimalPlaces: (json['decimalPlaces'] as num?)?.toInt(),
    isActive: json['active'] == true,
  );

  static const List<Unit> demo = [
    Unit(
      id: '1',
      name: 'Piece',
      symbol: 'PCS',
      icon: Icons.crop_square_rounded,
      color: Color(0xFF1D4ED8),
    ),
    Unit(
      id: '2',
      name: 'Kilogram',
      symbol: 'KGS',
      icon: Icons.balance_rounded,
      color: Color(0xFF059669),
    ),
    Unit(
      id: '3',
      name: 'Meter',
      symbol: 'MTR',
      icon: Icons.straighten_rounded,
      color: Color(0xFFD97706),
    ),
    Unit(
      id: '4',
      name: 'Liter',
      symbol: 'LTR',
      icon: Icons.local_drink_rounded,
      color: Color(0xFF7C3AED),
    ),
    Unit(
      id: '5',
      name: 'Box',
      symbol: 'BOX',
      icon: Icons.inventory_2_rounded,
      color: Color(0xFF3B82F6),
    ),
    Unit(
      id: '6',
      name: 'Dozen',
      symbol: 'DZN',
      isActive: false,
      icon: Icons.grid_view_rounded,
      color: Color(0xFF0D9488),
    ),
  ];
}
