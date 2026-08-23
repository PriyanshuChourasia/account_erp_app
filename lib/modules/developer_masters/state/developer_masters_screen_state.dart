import 'package:flutter/material.dart';

import '../../../config/theme/app_theme.dart';
import '../screens/developer_masters_screen.dart';
import '../widgets/master_card.dart';

/// State for [DeveloperMastersScreen]. Kept out of the screen file to follow
/// the StatefulWidget split pattern.
class DeveloperMastersScreenState extends State<DeveloperMastersScreen> {
  // No masters exist yet. Add entries here (and a matching case in
  // `_openMaster`) the same way `accounting_masters_screen_state.dart` and
  // `organisational_masters_screen_state.dart` do, e.g.:
  //
  // (
  //   title: 'API Keys',
  //   subtitle: 'Manage keys used to authenticate API requests',
  //   icon: Icons.vpn_key_rounded,
  //   color: Color(0xFF7C3AED),
  // ),
  static const _masters = <
    ({String title, String subtitle, IconData icon, Color color})
  >[];

  void _openMaster(int index) {
    // Wire up navigation to each sub-module's screen here once masters
    // exist, mirroring `accounting_masters_screen_state.dart`'s `_openMaster`.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage your developer master data.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _masters.isEmpty
                ? const _EmptyState()
                : GridView.extent(
                    maxCrossAxisExtent: 300,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.35,
                    children: [
                      for (final (index, master) in _masters.indexed)
                        MasterCard(
                          title: master.title,
                          subtitle: master.subtitle,
                          icon: master.icon,
                          color: master.color,
                          onTap: () => _openMaster(index),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Shown while no developer masters have been added yet.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.code_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No developer masters yet',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Masters added under this domain will show up here.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
