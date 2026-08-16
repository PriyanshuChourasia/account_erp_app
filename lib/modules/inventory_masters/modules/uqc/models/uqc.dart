import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// A Unit Quantity Code (UQC) — the GST-mandated code describing the unit an
/// item is measured in (e.g. `NOS` for Numbers, `KGS` for Kilograms).
///
/// Mirrors the backend `UqcDTO` record. [demo] serves as placeholder data
/// until the backend is reachable.
class Uqc {
  const Uqc({
    required this.id,
    required this.name,
    this.code,
    this.alias,
    this.description,
    this.isActive = true,
    this.icon = Icons.straighten_rounded,
    this.color = AppColors.primary,
  });

  final int id;
  final String name;

  /// GST UQC short code, e.g. `NOS`, `KGS`. Max 3 characters.
  final String? code;
  final String? alias;
  final String? description;
  final bool isActive;
  final IconData icon;
  final Color color;

  factory Uqc.fromJson(Map<String, dynamic> json) => Uqc(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    code: json['code'] as String?,
    alias: json['alias'] as String?,
    description: json['description'] as String?,
    isActive: json['isActive'] == true,
  );

  static const List<Uqc> demo = [
    Uqc(
      id: 1,
      name: 'Numbers',
      code: 'NOS',
      description: 'Used for countable items',
      icon: Icons.tag_rounded,
      color: Color(0xFF1D4ED8),
    ),
    Uqc(
      id: 2,
      name: 'Kilograms',
      code: 'KGS',
      description: 'Unit of mass',
      icon: Icons.balance_rounded,
      color: Color(0xFF059669),
    ),
    Uqc(
      id: 3,
      name: 'Litre',
      code: 'LTR',
      description: 'Unit of volume',
      icon: Icons.local_drink_rounded,
      color: Color(0xFFD97706),
    ),
    Uqc(
      id: 4,
      name: 'Meters',
      code: 'MTR',
      description: 'Unit of length',
      icon: Icons.straighten_rounded,
      color: Color(0xFF7C3AED),
    ),
    Uqc(
      id: 5,
      name: 'Boxes',
      code: 'BOX',
      isActive: false,
      icon: Icons.inventory_2_rounded,
      color: Color(0xFF3B82F6),
    ),
  ];
}
