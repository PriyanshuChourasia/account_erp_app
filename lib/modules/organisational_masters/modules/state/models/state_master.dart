import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// A state or region belonging to a country.
///
/// Mirrors the backend `StateDTO` record. `countryName` is a convenience
/// field for display, resolved from the country list when the backend does
/// not send it. [demo] serves as placeholder data until the backend is
/// reachable.
class StateMaster {
  const StateMaster({
    required this.id,
    required this.name,
    this.code,
    required this.countryId,
    this.countryName,
    this.description,
    this.isActive = true,
    this.icon = Icons.map_rounded,
    this.color = AppColors.primary,
  });

  final int id;
  final String name;

  /// e.g. state/region code like `MH` for Maharashtra.
  final String? code;
  final int countryId;
  final String? countryName;
  final String? description;
  final bool isActive;
  final IconData icon;
  final Color color;

  factory StateMaster.fromJson(Map<String, dynamic> json) => StateMaster(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    code: json['code'] as String?,
    countryId: (json['countryId'] as num?)?.toInt() ?? 0,
    countryName: json['countryName'] as String?,
    description: json['description'] as String?,
    isActive: json['isActive'] == true,
  );

  static const List<StateMaster> demo = [
    StateMaster(
      id: 1,
      name: 'Maharashtra',
      code: 'MH',
      countryId: 1,
      countryName: 'India',
      description: 'Western state of India',
      icon: Icons.map_rounded,
      color: Color(0xFF1D4ED8),
    ),
    StateMaster(
      id: 2,
      name: 'Karnataka',
      code: 'KA',
      countryId: 1,
      countryName: 'India',
      description: 'South-western state of India',
      icon: Icons.map_rounded,
      color: Color(0xFF0D9488),
    ),
    StateMaster(
      id: 3,
      name: 'Gujarat',
      code: 'GJ',
      countryId: 1,
      countryName: 'India',
      description: 'Western state of India',
      icon: Icons.map_rounded,
      color: Color(0xFFD97706),
    ),
    StateMaster(
      id: 4,
      name: 'California',
      code: 'CA',
      countryId: 2,
      countryName: 'United States',
      description: 'Western US state',
      icon: Icons.map_rounded,
      color: Color(0xFF7C3AED),
    ),
    StateMaster(
      id: 5,
      name: 'Texas',
      code: 'TX',
      countryId: 2,
      countryName: 'United States',
      description: 'South-central US state',
      icon: Icons.map_rounded,
      color: Color(0xFF059669),
    ),
    StateMaster(
      id: 6,
      name: 'Dubai',
      code: 'DU',
      countryId: 4,
      countryName: 'United Arab Emirates',
      description: 'Most populous emirate',
      icon: Icons.map_rounded,
      color: Color(0xFFDC2626),
    ),
  ];
}
