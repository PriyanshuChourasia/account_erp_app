import 'package:flutter/material.dart';

import '../../../config/theme/app_theme.dart';

/// Standalone Help screen. Reachable from anywhere in the app — logged in
/// or not — via the top-right quick-access bar or the `H` keyboard shortcut
/// (see `core/widgets/app_shortcuts_overlay.dart`).
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _topics = [
    (
      icon: Icons.rocket_launch_outlined,
      title: 'Getting started',
      body:
          'Sign in with your username and password. New here? Use "Create '
          'one" on the login screen to register an account.',
    ),
    (
      icon: Icons.dashboard_customize_outlined,
      title: 'Navigating the dashboard',
      body:
          'Use the sidebar to switch between Items, Accounting Masters, '
          'Inventory Masters, Organisational Masters and Utilities.',
    ),
    (
      icon: Icons.account_balance_outlined,
      title: 'Accounting & inventory masters',
      body:
          'Set up account groups, ledgers, stock groups and units before '
          'recording transactions — masters drive every downstream entry.',
    ),
    (
      icon: Icons.keyboard_outlined,
      title: 'Keyboard shortcuts',
      body:
          'Press H anywhere to open this Help screen, or S to open the '
          'Support Center — as long as you are not typing in a text field.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Help'),
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
            'How can we help?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Answers to the most common questions about Account ERP.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          for (final topic in _topics) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        topic.icon,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            topic.body,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
