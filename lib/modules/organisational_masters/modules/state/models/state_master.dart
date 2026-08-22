import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// A state or region belonging to a country.
///
/// Mirrors the backend `StateDTO` record (`id`/`countryId` are UUID strings;
/// `countryName` is kept as a convenience display field). [demo] serves as
/// placeholder data until the backend is reachable.
class StateMaster {
  const StateMaster({
    required this.id,
    required this.name,
    this.code,
    this.gstCode,
    required this.countryId,
    this.countryName,
    this.description,
    this.active = true,
    this.icon = Icons.map_rounded,
    this.color = AppColors.primary,
  });

  /// UUID from the backend.
  final String id;
  final String name;

  /// e.g. state/region code like `MH` for Maharashtra.

  final String? code;

  /// GST state code, e.g. `27` for Maharashtra.
  final String? gstCode;

  /// UUID of the country this state belongs to.
  final String countryId;
  final String? countryName;
  final String? description;
  final bool active;
  final IconData icon;
  final Color color;

  factory StateMaster.fromJson(Map<String, dynamic> json) => StateMaster(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    code: json['code'] as String?,
    gstCode: json['gstCode'] as String?,
    countryId: json['countryId'] as String? ?? '',
    countryName: json['countryName'] as String?,
    description: json['description'] as String?,
    active: json['active'] == true,
  );

  static const List<StateMaster> demo = [
    StateMaster(
      id: '00000000-0000-0000-0000-000000000001',
      name: 'Maharashtra',
      code: 'MH',
      gstCode: '27',
      countryId: '00000000-0000-0000-0000-000000000001',
      countryName: 'India',
      description: 'Western state of India',
      icon: Icons.map_rounded,
      color: Color(0xFF1D4ED8),
    ),
    StateMaster(
      id: '00000000-0000-0000-0000-000000000002',
      name: 'Karnataka',
      code: 'KA',
      gstCode: '29',
      countryId: '00000000-0000-0000-0000-000000000001',
      countryName: 'India',
      description: 'South-western state of India',
      icon: Icons.map_rounded,
      color: Color(0xFF0D9488),
    ),
    StateMaster(
      id: '00000000-0000-0000-0000-000000000003',
      name: 'Gujarat',
      code: 'GJ',
      gstCode: '24',
      countryId: '00000000-0000-0000-0000-000000000001',
      countryName: 'India',
      description: 'Western state of India',
      icon: Icons.map_rounded,
      color: Color(0xFFD97706),
    ),
    StateMaster(
      id: '00000000-0000-0000-0000-000000000004',
      name: 'California',
      code: 'CA',
      countryId: '00000000-0000-0000-0000-000000000002',
      countryName: 'United States',
      description: 'Western US state',
      icon: Icons.map_rounded,
      color: Color(0xFF7C3AED),
    ),
    StateMaster(
      id: '00000000-0000-0000-0000-000000000005',
      name: 'Texas',
      code: 'TX',
      countryId: '00000000-0000-0000-0000-000000000002',
      countryName: 'United States',
      description: 'South-central US state',
      icon: Icons.map_rounded,
      color: Color(0xFF059669),
    ),
    StateMaster(
      id: '00000000-0000-0000-0000-000000000006',
      name: 'Dubai',
      code: 'DU',
      countryId: '00000000-0000-0000-0000-000000000004',
      countryName: 'United Arab Emirates',
      description: 'Most populous emirate',
      icon: Icons.map_rounded,
      color: Color(0xFFDC2626),
    ),
  ];
}
