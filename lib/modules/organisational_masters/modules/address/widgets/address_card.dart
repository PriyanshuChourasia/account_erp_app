import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/address.dart';

/// Row card for a single address.
class AddressCard extends StatelessWidget {
  const AddressCard({super.key, required this.address, this.onDelete});

  final Address address;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lines = [
      if (address.line2 != null) address.line2!,
      if (address.city != null) address.city!,
      if (address.area != null) address.area!,
      if (address.postOffice != null) address.postOffice!,
      if (address.landmark != null) 'Near ${address.landmark}',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: address.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(address.icon, color: address.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${address.addressType} · ${address.line1}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (lines.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      lines.join(', '),
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
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                address.pinCode,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            if (address.isPrimary)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.star_rounded,
                  size: 18,
                  color: AppColors.gradientGreen.first,
                ),
              ),
            if (onDelete != null)
              IconButton(
                tooltip: 'Delete address',
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
