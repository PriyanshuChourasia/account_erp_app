import 'package:flutter/material.dart';

import '../../../config/theme/app_theme.dart';

/// Standalone Support Center screen. Reachable from anywhere in the app —
/// logged in or not — via the top-right quick-access bar or the `S`
/// keyboard shortcut (see `core/widgets/app_shortcuts_overlay.dart`).
class SupportCenterScreen extends StatelessWidget {
  const SupportCenterScreen({super.key});

  static const _channels = [
    (
      icon: Icons.mail_outline_rounded,
      title: 'Email support',
      subtitle: 'support@accounterp.app',
    ),
    (
      icon: Icons.call_outlined,
      title: 'Call us',
      subtitle: '+91 98765 43210 (Mon–Sat, 9am–6pm)',
    ),
    (
      icon: Icons.chat_bubble_outline_rounded,
      title: 'Live chat',
      subtitle: 'Available for signed-in users from the dashboard',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Support Center'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Close',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'We\'re here to help',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Reach the Account ERP support team through any of these '
            'channels.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          for (final channel in _channels) ...[
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(channel.icon, color: AppColors.primary, size: 22),
                ),
                title: Text(
                  channel.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  channel.subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
