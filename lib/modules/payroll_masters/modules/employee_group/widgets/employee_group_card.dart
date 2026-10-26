import 'package:flutter/material.dart';

import '../../../../../../config/theme/app_theme.dart';
import '../models/employee_group.dart';

/// Row card for a single employee group.
class EmployeeGroupCard extends StatelessWidget {
  const EmployeeGroupCard({
    super.key,
    required this.group,
    this.onEdit,
    this.onDelete,
    this.selected = false,
  });

  final EmployeeGroup group;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  /// Highlights the card while it is loaded in the edit form.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = group.code ?? '—';

    return Card(
      margin: EdgeInsets.zero,
      color: selected ? AppColors.primary.withValues(alpha: 0.06) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected
              ? AppColors.primary
              : AppColors.textSecondary.withValues(alpha: 0.18),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: group.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(group.icon, color: group.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Code and status share a line, wrapping when narrow.
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: group.isActive
                                ? AppColors.gradientGreen.first.withValues(
                                    alpha: 0.12,
                                  )
                                : AppColors.textSecondary.withValues(
                                    alpha: 0.1,
                                  ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            group.isActive ? 'Active' : 'Inactive',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: group.isActive
                                  ? AppColors.gradientGreen.first
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (group.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        group.description!,
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
              const SizedBox(width: 8),
              if (onEdit != null)
                IconButton(
                  tooltip: 'Edit employee group',
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: onEdit,
                ),
              if (onDelete != null)
                IconButton(
                  tooltip: 'Delete employee group',
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
      ),
    );
  }
}
