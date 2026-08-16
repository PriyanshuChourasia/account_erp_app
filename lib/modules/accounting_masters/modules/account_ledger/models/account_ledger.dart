import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// A ledger account, e.g. `Cash`, `Sundry Debtors` or `Sales`.
///
/// Mirrors the backend `AccountLedgerDTO` record. `groupName` is a convenience
/// field for display, resolved from the account group list when the backend
/// does not send it. [demo] serves as placeholder data until the backend is
/// reachable.
class AccountLedger {
  const AccountLedger({
    required this.id,
    required this.name,
    this.alias,
    this.description,
    this.groupId,
    this.groupName,
    this.isActive = true,
    this.icon = Icons.menu_book_rounded,
    this.color = AppColors.primary,
  });

  final int id;
  final String name;
  final String? alias;
  final String? description;

  /// Parent account group id — ledgers are classified under account groups.
  final int? groupId;
  final String? groupName;
  final bool isActive;
  final IconData icon;
  final Color color;

  factory AccountLedger.fromJson(Map<String, dynamic> json) => AccountLedger(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    alias: json['alias'] as String?,
    description: json['description'] as String?,
    groupId: (json['groupId'] as num?)?.toInt(),
    groupName: json['groupName'] as String?,
    isActive: json['isActive'] == true,
  );

  static const List<AccountLedger> demo = [
    AccountLedger(
      id: 1,
      name: 'Cash in Hand',
      alias: 'Cash',
      description: 'Physical cash held by the business',
      groupId: 2,
      groupName: 'Current Assets',
      icon: Icons.payments_rounded,
      color: Color(0xFF059669),
    ),
    AccountLedger(
      id: 2,
      name: 'Sundry Debtors',
      alias: 'Receivables',
      description: 'Customers who owe money',
      groupId: 2,
      groupName: 'Current Assets',
      icon: Icons.people_alt_rounded,
      color: Color(0xFF1D4ED8),
    ),
    AccountLedger(
      id: 3,
      name: 'Sundry Creditors',
      alias: 'Payables',
      description: 'Suppliers the business owes money to',
      groupId: 4,
      groupName: 'Current Liabilities',
      icon: Icons.storefront_rounded,
      color: Color(0xFF0D9488),
    ),
    AccountLedger(
      id: 4,
      name: 'Sales',
      description: 'Revenue from selling goods or services',
      groupId: 6,
      groupName: 'Direct Income',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFF7C3AED),
    ),
    AccountLedger(
      id: 5,
      name: 'Salary Expense',
      description: 'Employee compensation',
      groupId: 8,
      groupName: 'Indirect Expense',
      icon: Icons.payments_outlined,
      color: Color(0xFFDC2626),
    ),
  ];
}
