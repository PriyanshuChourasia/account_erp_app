import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/financial_year.dart';
import '../utils/date_helpers.dart';

/// Row card for a single financial year.
class FinancialYearCard extends StatelessWidget {
  const FinancialYearCard({
    super.key,
    required this.financialYear,
    this.onSetCurrent,
  });

  final FinancialYear financialYear;
  final VoidCallback? onSetCurrent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = [
      '${financialYear.id}',
      if (financialYear.code != null) financialYear.code!,
      if (financialYear.startDate != null)
        '${formatFinancialDateString(financialYear.startDate)} → '
            '${formatFinancialDateString(financialYear.endDate)}',
    ].join(' · ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: financialYear.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                financialYear.icon,
                color: financialYear.color,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          financialYear.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (financialYear.isCurrent) ...[
                        const SizedBox(width: 8),
                        const _CurrentBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (financialYear.isCurrent)
              const Icon(Icons.star_rounded, size: 20, color: AppColors.primary)
            else if (onSetCurrent != null)
              IconButton(
                tooltip: 'Set as current year',
                icon: const Icon(
                  Icons.star_outline_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onPressed: onSetCurrent,
              ),
          ],
        ),
      ),
    );
  }
}

class _CurrentBadge extends StatelessWidget {
  const _CurrentBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Current',
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
