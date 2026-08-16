import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/unique_quantity_code.dart';

/// Row card for a single UQC.
class UniqueQuantityCodeCard extends StatelessWidget {
  const UniqueQuantityCodeCard({super.key, required this.uqc, this.onEdit});

  final UniqueQuantityCode uqc;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = [
      '${uqc.id}',
      if (uqc.code != null) uqc.code!,
      if (uqc.alias != null) 'aka ${uqc.alias}',
    ].join(' · ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: uqc.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(uqc.icon, color: uqc.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    uqc.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
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
                  if (uqc.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      uqc.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: uqc.isActive
                    ? AppColors.gradientGreen.first.withValues(alpha: 0.12)
                    : AppColors.textSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                uqc.isActive ? 'Active' : 'Inactive',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: uqc.isActive
                      ? AppColors.gradientGreen.first
                      : AppColors.textSecondary,
                ),
              ),
            ),
            if (onEdit != null)
              IconButton(
                tooltip: 'Edit UQC',
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onPressed: onEdit,
              ),
          ],
        ),
      ),
    );
  }
}
