import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// An accounting group used to classify ledgers.
///
/// Mirrors the backend `AccountGroupDTO` record.
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

  final String id;
  final String name;
  final int? code;
  final String? alias;
  final String? description;
  final bool isActive;

  /// Parent group id — accounting groups form a hierarchy (e.g. `Sundry
  /// Debtors` sits under `Current Assets`).
  final String? parentId;

  /// The account nature this group belongs to.
  final String? accountNatureId;
  final IconData icon;
  final Color color;

  factory AccountGroup.fromJson(Map<String, dynamic> json) => AccountGroup(
    id: json['id']?.toString() ?? '',
    name: json['name'] as String? ?? '',
    code: (json['code'] as num?)?.toInt(),
    alias: json['alias'] as String?,
    description: json['description'] as String?,
    isActive: json['isActive'] == true,
    parentId: json['parentId']?.toString(),
    accountNatureId: json['accountNatureId']?.toString(),
  );
}
