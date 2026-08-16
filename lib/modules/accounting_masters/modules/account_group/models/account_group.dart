import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// An accounting group used to classify ledgers.
///
/// Mirrors the backend `AccountGroupDTO` record. [demo] serves as placeholder
/// data until the backend is reachable.
class AccountGroup {
  const AccountGroup({
    required this.id,
    required this.name,
    this.code,
    this.alias,
    this.description,
    this.isActive = true,
    this.parentId,
    this.accountNatureId,
    this.icon = Icons.account_tree_rounded,
    this.color = AppColors.primary,
  });

  final int id;
  final String name;
  final int? code;
  final String? alias;
  final String? description;
  final bool isActive;

  /// Parent group id — accounting groups form a hierarchy (e.g. `Sundry
  /// Debtors` sits under `Current Assets`).
  final int? parentId;

  /// The account nature this group belongs to.
  final int? accountNatureId;
  final IconData icon;
  final Color color;

  factory AccountGroup.fromJson(Map<String, dynamic> json) => AccountGroup(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    code: (json['code'] as num?)?.toInt(),
    alias: json['alias'] as String?,
    description: json['description'] as String?,
    isActive: json['isActive'] == true,
    parentId: (json['parentId'] as num?)?.toInt(),
    accountNatureId: (json['accountNatureId'] as num?)?.toInt(),
  );

  static const List<AccountGroup> demo = [
    AccountGroup(
      id: 1,
      name: 'Capital Account',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF7C3AED),
    ),
    AccountGroup(
      id: 2,
      name: 'Current Assets',
      description: 'Assets expected to convert to cash within a year',
      icon: Icons.paid_rounded,
      color: Color(0xFF059669),
    ),
    AccountGroup(
      id: 3,
      name: 'Sundry Debtors',
      alias: 'Receivables',
      description: 'Customers who owe money for goods or services',
      parentId: 2,
      icon: Icons.people_alt_rounded,
      color: Color(0xFF1D4ED8),
    ),
    AccountGroup(
      id: 4,
      name: 'Current Liabilities',
      icon: Icons.receipt_rounded,
      color: Color(0xFFD97706),
    ),
    AccountGroup(
      id: 5,
      name: 'Sundry Creditors',
      alias: 'Payables',
      description: 'Suppliers the business owes money to',
      parentId: 4,
      icon: Icons.storefront_rounded,
      color: Color(0xFF0D9488),
    ),
    AccountGroup(
      id: 6,
      name: 'Direct Income',
      icon: Icons.trending_up_rounded,
      color: Color(0xFF3B82F6),
    ),
    AccountGroup(
      id: 7,
      name: 'Sales',
      description: 'Revenue from selling goods or services',
      parentId: 6,
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFF7C3AED),
    ),
    AccountGroup(
      id: 8,
      name: 'Indirect Expense',
      icon: Icons.money_off_rounded,
      color: Color(0xFFDC2626),
    ),
  ];
}
