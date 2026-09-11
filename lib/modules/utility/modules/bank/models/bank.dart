import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// A bank that holds accounts, e.g. `State Bank of India`.
///
/// Mirrors the backend `BankDTO` record. `bankTypeName` is a convenience field
/// for display, resolved from the bank type list when the backend does not
/// send it. [demo] serves as placeholder data until the backend is reachable.
class Bank {
  const Bank({
    required this.id,
    required this.name,
    this.code,
    this.bankTypeId,
    this.bankTypeName,
    this.description,
    this.isActive = true,
    this.icon = Icons.account_balance_rounded,
    this.color = AppColors.primary,
  });

  final int id;
  final String name;

  /// Short bank code, e.g. `SBI`.
  final String? code;

  /// Parent bank type id — banks are classified under bank types.
  final int? bankTypeId;
  final String? bankTypeName;
  final String? description;
  final bool isActive;
  final IconData icon;
  final Color color;

  factory Bank.fromJson(Map<String, dynamic> json) => Bank(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    code: json['code'] as String?,
    bankTypeId: (json['bankTypeId'] as num?)?.toInt(),
    bankTypeName: json['bankTypeName'] as String?,
    description: json['description'] as String?,
    isActive: json['isActive'] == true,
  );

  static const List<Bank> demo = [
    Bank(
      id: 1,
      name: 'State Bank of India',
      code: 'SBI',
      bankTypeId: 1,
      bankTypeName: 'Nationalised Bank',
      description: 'Largest public sector bank in India',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF1D4ED8),
    ),
    Bank(
      id: 2,
      name: 'HDFC Bank',
      code: 'HDFC',
      bankTypeId: 2,
      bankTypeName: 'Private Bank',
      description: 'Leading private sector bank',
      icon: Icons.business_rounded,
      color: Color(0xFF059669),
    ),
    Bank(
      id: 3,
      name: 'Punjab National Bank',
      code: 'PNB',
      bankTypeId: 1,
      bankTypeName: 'Nationalised Bank',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF7C3AED),
    ),
  ];
}