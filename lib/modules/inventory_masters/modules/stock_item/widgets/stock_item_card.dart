import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/stock_item.dart';

/// Row card for a single stock item.
class StockItemCard extends StatelessWidget {
  const StockItemCard({super.key, required this.item, this.onDelete});

  final StockItem item;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = [
      '${item.id}',
      if (item.code != null) item.code!,
      if (item.alias != null) 'aka ${item.alias}',
    ].join(' · ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
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
                  if (item.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.description!,
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
                color: item.isActive
                    ? AppColors.gradientGreen.first.withValues(alpha: 0.12)
                    : AppColors.textSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item.isActive ? 'Active' : 'Inactive',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: item.isActive
                      ? AppColors.gradientGreen.first
                      : AppColors.textSecondary,
                ),
              ),
            ),
            if (onDelete != null)
              IconButton(
                tooltip: 'Delete item',
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
