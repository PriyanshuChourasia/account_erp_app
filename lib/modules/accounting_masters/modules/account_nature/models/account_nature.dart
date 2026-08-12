import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// An account nature used to classify ledgers, e.g. `Asset`, `Liability`,
/// `Income`, `Expense` or `Equity`.
///
/// Mirrors the backend `AccountNatureDTO` record. [demo] serves as placeholder
/// data until the backend is reachable.
class AccountNature {
  const AccountNature({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.icon = Icons.category_rounded,
    this.color = AppColors.primary,
  });

  final int id;
  final String name;
  final int? code;
  final String? description;
  final IconData icon;
  final Color color;

  factory AccountNature.fromJson(Map<String, dynamic> json) => AccountNature(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        code: (json['code'] as num?)?.toInt(),
        description: json['description'] as String?,
      );

  static const List<AccountNature> demo = [
    AccountNature(
      id: 1,
      name: 'Asset',
      code: 1,
      description: 'Resources owned by the business',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF059669),
    ),
    AccountNature(
      id: 2,
      name: 'Liability',
      code: 2,
      description: 'Obligations owed to others',
      icon: Icons.receipt_rounded,
      color: Color(0xFFD97706),
    ),
    AccountNature(
      id: 3,
      name: 'Income',
      code: 3,
      description: 'Revenue earned by the business',
      icon: Icons.trending_up_rounded,
      color: Color(0xFF1D4ED8),
    ),
    AccountNature(
      id: 4,
      name: 'Expense',
      code: 4,
      description: 'Costs incurred by the business',
      icon: Icons.money_off_rounded,
      color: Color(0xFFDC2626),
    ),
    AccountNature(
      id: 5,
      name: 'Equity',
      code: 5,
      description: 'Owners stake in the business',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF7C3AED),
    ),
  ];
}
