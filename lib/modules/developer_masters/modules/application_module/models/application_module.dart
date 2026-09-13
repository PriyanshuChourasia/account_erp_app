import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// A registered module of the ERP application (e.g. `Accounting Masters`,
/// `Inventory Masters`), used to drive navigation and feature grouping.
///
/// Mirrors the backend `ApplicationModuleDTO` record. [demo] serves as
/// placeholder data until the backend is reachable.
class ApplicationModule {
  const ApplicationModule({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.endpoint,
    this.isSystem = false,
    this.version,
    this.active = true,
    this.icon = Icons.widgets_rounded,
    this.color = AppColors.primary,
  });

  /// UUID assigned by the backend.
  final String id;
  final String name;
  final String? code;
  final String? description;
  final String? endpoint;
  final bool isSystem;
  final int? version;
  final bool active;
  final IconData icon;
  final Color color;

  factory ApplicationModule.fromJson(Map<String, dynamic> json) =>
      ApplicationModule(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        code: json['code'] as String?,
        description: json['description'] as String?,
        endpoint: json['endpoint'] as String?,
        isSystem: json['isSystem'] == true,
        version: (json['version'] as num?)?.toInt(),
        active: json['active'] as bool? ?? true,
      );

  static const List<ApplicationModule> demo = [
    ApplicationModule(
      id: '1',
      name: 'Accounting Masters',
      code: 'ACC',
      description: 'Ledgers, account groups, natures and vouchers',
      endpoint: 'accounting-masters',
      version: 1,
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF0D9488),
    ),
    ApplicationModule(
      id: '2',
      name: 'Inventory Masters',
      code: 'INV',
      description: 'Stock groups, categories and items',
      endpoint: 'inventory-masters',
      version: 1,
      icon: Icons.warehouse_rounded,
      color: Color(0xFF7C3AED),
    ),
    ApplicationModule(
      id: '3',
      name: 'Organisational Masters',
      code: 'ORG',
      description: 'Countries, states and company structure',
      endpoint: 'organisational-masters',
      version: 1,
      icon: Icons.apartment_rounded,
      color: Color(0xFF1D4ED8),
    ),
    ApplicationModule(
      id: '4',
      name: 'Developer Masters',
      code: 'DEV',
      description: 'Application modules and features registry',
      endpoint: 'developer-masters',
      isSystem: true,
      version: 1,
      icon: Icons.code_rounded,
      color: Color(0xFFD97706),
    ),
  ];
}
