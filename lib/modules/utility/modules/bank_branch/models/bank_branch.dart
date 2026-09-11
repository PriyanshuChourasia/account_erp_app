import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';

/// A branch of a bank, e.g. `SBI - Andheri West`.
///
/// Mirrors the backend `BankBranchDTO` record. `bankName` is a convenience
/// field for display, resolved from the bank list when the backend does not
/// send it. [demo] serves as placeholder data until the backend is reachable.
class BankBranch {
  const BankBranch({
    required this.id,
    required this.name,
    this.bankId,
    this.bankName,
    this.ifscCode,
    this.address,
    this.isActive = true,
    this.icon = Icons.store_mall_directory_rounded,
    this.color = AppColors.primary,
  });

  final int id;
  final String name;

  /// Parent bank id — branches belong to banks.
  final int? bankId;
  final String? bankName;

  /// IFSC code of the branch, e.g. `SBIN0001234`.
  final String? ifscCode;
  final String? address;
  final bool isActive;
  final IconData icon;
  final Color color;

  factory BankBranch.fromJson(Map<String, dynamic> json) => BankBranch(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    bankId: (json['bankId'] as num?)?.toInt(),
    bankName: json['bankName'] as String?,
    ifscCode: json['ifscCode'] as String?,
    address: json['address'] as String?,
    isActive: json['isActive'] == true,
  );

  static const List<BankBranch> demo = [
    BankBranch(
      id: 1,
      name: 'SBI - Andheri West',
      bankId: 1,
      bankName: 'State Bank of India',
      ifscCode: 'SBIN0001234',
      address: 'Andheri West, Mumbai',
      icon: Icons.store_mall_directory_rounded,
      color: Color(0xFF1D4ED8),
    ),
    BankBranch(
      id: 2,
      name: 'HDFC - Bandra Kurla Complex',
      bankId: 2,
      bankName: 'HDFC Bank',
      ifscCode: 'HDFC0005678',
      address: 'Bandra East, Mumbai',
      icon: Icons.business_rounded,
      color: Color(0xFF059669),
    ),
    BankBranch(
      id: 3,
      name: 'PNB - Connaught Place',
      bankId: 3,
      bankName: 'Punjab National Bank',
      ifscCode: 'PUNB0009012',
      address: 'Connaught Place, New Delhi',
      icon: Icons.location_city_rounded,
      color: Color(0xFF7C3AED),
    ),
  ];
}