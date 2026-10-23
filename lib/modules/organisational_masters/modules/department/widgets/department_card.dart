import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/department.dart';

/// Card for a single department.
class DepartmentCard extends StatelessWidget {
  const DepartmentCard({
    super.key,
    required this.department,
    required this.onActiveChanged,
    required this.onEdit,
    required this.onDelete,
    this.isToggling = false,
  });

  final Department department;
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
                color: department.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(department.icon, color: department.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    department.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    department.code ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: department.isActive,
              onChanged: isToggling ? null : onActiveChanged,
            ),
            IconButton(
              tooltip: 'Edit department',
              icon: const Icon(
                Icons.edit_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
              onPressed: onEdit,
            ),
            IconButton(
              tooltip: 'Delete department',
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
