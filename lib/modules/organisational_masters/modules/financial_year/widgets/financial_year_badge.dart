import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/financial_year.dart';

/// Read-only display of a financial year — a calendar icon plus the year's
/// name, or a muted placeholder when none is selected. Used both in the
/// global header (`AppShortcutsOverlay`, showing the app-wide selected
/// year) and in the create-company screen (showing the year picked for that
/// company). Purely a display; pair it with a separate action for creating
/// a new year rather than making the badge itself tappable.
class FinancialYearBadge extends StatelessWidget {
  const FinancialYearBadge({super.key, required this.financialYear});

  final FinancialYear? financialYear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final year = financialYear;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_month_rounded,
            size: 16,
            color: year == null ? AppColors.textSecondary : AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            year?.name ?? 'No financial year',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: year == null
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
