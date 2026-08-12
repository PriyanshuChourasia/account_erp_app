import 'package:flutter/material.dart';

import '../../../config/theme/app_theme.dart';

/// A single stat card shown on the dashboard grid.
///
/// NOTE: This currently serves demo data. When the backend is wired, replace
/// it with an API-driven model (see `dashboard/` TODO in the view model).
class DashboardStat {
  const DashboardStat({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  final String title;
  final num value;
  final IconData icon;
  final List<Color> gradient;

  /// Placeholder stats until the dashboard API is connected.
  static const List<DashboardStat> demo = [
    DashboardStat(
      title: 'Ledger entries',
      value: 1284,
      icon: Icons.menu_book_rounded,
      gradient: AppColors.gradientBlue,
    ),
    DashboardStat(
      title: 'Invoices',
      value: 96,
      icon: Icons.receipt_long_rounded,
      gradient: AppColors.gradientGreen,
    ),
    DashboardStat(
      title: 'Reports',
      value: 12,
      icon: Icons.bar_chart_rounded,
      gradient: AppColors.gradientAmber,
    ),
    DashboardStat(
      title: 'Pending approvals',
      value: 3,
      icon: Icons.pending_actions_rounded,
      gradient: AppColors.gradientPurple,
    ),
  ];
}
