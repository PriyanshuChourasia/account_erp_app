import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// A classification of banks, e.g. `Nationalised`, `Private` or `Co-operative`.
///
/// Mirrors the backend `BankTypeDTO` record. [demo] serves as placeholder data
/// until the backend is reachable.
class BankType {
  const BankType({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
    this.icon = Icons.category_outlined,
    this.color = AppColors.primary,
  });

  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final IconData icon;
  final Color color;

  factory BankType.fromJson(Map<String, dynamic> json) => BankType(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    description: json['description'] as String?,
    isActive: json['isActive'] == true,
  );

  static const List<BankType> demo = [
    BankType(
      id: 1,
      name: 'Nationalised Bank',
      description: 'Government-owned commercial banks',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF1D4ED8),
    ),
    BankType(
      id: 2,
      name: 'Private Bank',
      description: 'Privately owned commercial banks',
      icon: Icons.business_rounded,
      color: Color(0xFF059669),
    ),
    BankType(
      id: 3,
      name: 'Co-operative Bank',
      description: 'Co-operative financial institutions',
      icon: Icons.groups_rounded,
      color: Color(0xFF7C3AED),
    ),
    BankType(
      id: 4,
      name: 'Regional Rural Bank',
      icon: Icons.house_rounded,
      color: Color(0xFFD97706),
    ),
  ];
}