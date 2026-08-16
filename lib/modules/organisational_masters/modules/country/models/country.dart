import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// A country used by organisational masters.
///
/// Mirrors the backend `CountryDTO` record. [demo] serves as placeholder data
/// until the backend is reachable.
class Country {
  const Country({
    required this.id,
    required this.name,
    this.code,
    this.alias,
    this.description,
    this.isActive = true,
    this.icon = Icons.public_rounded,
    this.color = AppColors.primary,
  });

  final int id;
  final String name;

  /// ISO 3166-1 alpha-2 country code, e.g. `IN`.
  final String? code;
  final String? alias;
  final String? description;
  final bool isActive;
  final IconData icon;
  final Color color;

  factory Country.fromJson(Map<String, dynamic> json) => Country(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    code: json['code'] as String?,
    alias: json['alias'] as String?,
    description: json['description'] as String?,
    isActive: json['isActive'] == true,
  );

  static const List<Country> demo = [
    Country(
      id: 1,
      name: 'India',
      code: 'IN',
      description: 'Republic of India',
      icon: Icons.flag_rounded,
      color: Color(0xFF0D9488),
    ),
    Country(
      id: 2,
      name: 'United States',
      code: 'US',
      description: 'United States of America',
      icon: Icons.flag_rounded,
      color: Color(0xFF1D4ED8),
    ),
    Country(
      id: 3,
      name: 'United Kingdom',
      code: 'GB',
      description: 'United Kingdom of Great Britain',
      icon: Icons.flag_rounded,
      color: Color(0xFF7C3AED),
    ),
    Country(
      id: 4,
      name: 'United Arab Emirates',
      code: 'AE',
      description: 'United Arab Emirates',
      icon: Icons.flag_rounded,
      color: Color(0xFFD97706),
    ),
    Country(
      id: 5,
      name: 'Singapore',
      code: 'SG',
      description: 'Republic of Singapore',
      icon: Icons.flag_rounded,
      color: Color(0xFF059669),
    ),
  ];
}
