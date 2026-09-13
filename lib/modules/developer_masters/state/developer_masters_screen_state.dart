import 'package:flutter/material.dart';

import '../../../config/theme/app_theme.dart';
import '../modules/application_module/screens/application_module_screen.dart';
import '../modules/application_feature/screens/application_feature_screen.dart';
import '../screens/developer_masters_screen.dart';
import '../widgets/master_card.dart';

/// State for [DeveloperMastersScreen]. Kept out of the screen file to follow
/// the StatefulWidget split pattern.
class DeveloperMastersScreenState extends State<DeveloperMastersScreen> {
  static const _masters = [
    (
      title: 'Application Module',
      subtitle: 'Registry of the ERP\'s own modules',
      icon: Icons.widgets_rounded,
      color: Color(0xFFD97706),
    ),
    (
      title: 'Application Feature',
      subtitle: 'Features belonging to each application module',
      icon: Icons.extension_rounded,
      color: Color(0xFF7C3AED),
    ),
    // Add more masters here: API Keys, Webhooks, Environments, ...
  ];

  void _openMaster(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const ApplicationModuleScreen(),
          ),
        );
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const ApplicationFeatureScreen(),
          ),
        );
    }
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
            child: GridView.extent(
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
