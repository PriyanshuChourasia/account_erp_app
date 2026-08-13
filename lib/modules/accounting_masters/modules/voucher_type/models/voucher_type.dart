import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// A voucher type used to classify accounting vouchers, e.g. `Payment`,
/// `Receipt`, `Journal`, `Sales` or `Purchase`.
///
/// Mirrors the backend `VoucherTypeDTO` record.
class VoucherType {
  const VoucherType({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.icon = Icons.receipt_long_rounded,
    this.color = AppColors.primary,
  });

  final int id;
  final String name;

  /// Short voucher-type code, e.g. `PAY`.
  final String? code;
  final String? description;
  final IconData icon;
  final Color color;

  factory VoucherType.fromJson(Map<String, dynamic> json) => VoucherType(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        code: json['code'] as String?,
        description: json['description'] as String?,
      );
}
