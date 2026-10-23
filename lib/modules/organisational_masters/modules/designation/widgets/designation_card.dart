import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/designation.dart';

/// Card for a single designation.
class DesignationCard extends StatelessWidget {
  const DesignationCard({
    super.key,
    required this.designation,
    required this.onActiveChanged,
    required this.onEdit,
    required this.onDelete,
    this.isToggling = false,
  });

  final Designation designation;
  final ValueChanged<bool> onActiveChanged;

  /// True while a status change is being saved; disables the switch.
  final bool isToggling;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: designation.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(designation.icon, color: designation.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    designation.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    designation.code ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: designation.isActive,
              onChanged: isToggling ? null : onActiveChanged,
            ),
            IconButton(
              tooltip: 'Edit designation',
              icon: const Icon(
                Icons.edit_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
              onPressed: onEdit,
            ),
            IconButton(
              tooltip: 'Delete designation',
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
