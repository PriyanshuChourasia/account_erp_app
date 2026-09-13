import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/application_feature.dart';

/// Row card for a single application feature.
class ApplicationFeatureCard extends StatelessWidget {
  const ApplicationFeatureCard({super.key, required this.feature, this.onDelete});

  final ApplicationFeature feature;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = [
      feature.apiMethod.name.toUpperCase(),
      feature.endPoint,
    ].join(' · ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: feature.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(feature.icon, color: feature.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature.name,
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
                  if (feature.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      feature.description!,
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
            _StatusBadge(active: feature.active),
            if (onDelete != null)
              IconButton(
                tooltip: 'Delete feature',
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? AppColors.gradientGreen.first.withValues(alpha: 0.12)
            : AppColors.textSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        active ? 'Active' : 'Inactive',
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: active ? AppColors.gradientGreen.first : AppColors.textSecondary,
        ),
      ),
    );
  }
}
