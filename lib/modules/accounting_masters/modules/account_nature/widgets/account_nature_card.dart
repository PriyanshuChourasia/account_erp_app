import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/account_nature.dart';

/// Row card for a single account nature.
class AccountNatureCard extends StatelessWidget {
  const AccountNatureCard({super.key, required this.nature, this.onDelete});

  final AccountNature nature;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = [
      '${nature.id}',
      if (nature.code != null) 'code ${nature.code}',
    ].join(' · ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: nature.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(nature.icon, color: nature.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nature.name,
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
                  if (nature.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      nature.description!,
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
            if (onDelete != null)
              IconButton(
                tooltip: 'Delete nature',
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
