import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// A financial (fiscal) year used to group accounting transactions.
///
/// Mirrors the backend `FinancialYearDTO` record (see
/// `CreateFinancialYearDTO`/`FinancialYearDTO`): `id`, `name`, `code`,
/// `startDate`, `endDate`, `isCurrent`. Dates arrive from the backend as ISO
/// `yyyy-MM-dd` strings and are kept as-is (see `utils/` for formatting
/// helpers).
class FinancialYear {
  const FinancialYear({
    required this.id,
    required this.name,
    this.code,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.icon = Icons.calendar_month_rounded,
    this.color = AppColors.primary,
  });

  final int id;
  final String name;

  /// Short fiscal-year code, e.g. `FY2425`.
  final String? code;

  /// `yyyy-MM-dd`, e.g. `2024-04-01`.
  final String? startDate;
  final String? endDate;

  /// True when this is the fiscal year currently in use for transactions.
  final bool isCurrent;
  final IconData icon;
  final Color color;

  factory FinancialYear.fromJson(Map<String, dynamic> json) => FinancialYear(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    code: json['code'] as String?,
    startDate: json['startDate'] as String?,
    endDate: json['endDate'] as String?,
    isCurrent: json['isCurrent'] == true,
  );
}
