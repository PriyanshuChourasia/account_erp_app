import 'package:flutter/material.dart';

import '../../../../config/theme/app_theme.dart';
import '../modules/calculator/screens/calculator_screen.dart';
import '../modules/database_opr/screens/database_opr_screen.dart';
import '../modules/terminal/screens/terminal_screen.dart';
import '../screens/utility_screen.dart';
import '../widgets/utility_card.dart';

/// State for [UtilityScreen]. Kept out of the screen file to follow the
/// StatefulWidget split pattern.
class UtilityScreenState extends State<UtilityScreen> {
  static const _utilities = [
    (
      title: 'Calculator',
      subtitle: 'Perform quick arithmetic calculations',
      icon: Icons.calculate_rounded,
      color: Color(0xFF1D4ED8),
    ),
    (
      title: 'Terminal',
      subtitle: 'Command-line simulator with a few handy commands',
      icon: Icons.terminal_rounded,
      color: Color(0xFF0D9488),
    ),
    (
      title: 'Database Operations',
      subtitle: 'Backup, restore, migrate and optimize your database',
      icon: Icons.storage_rounded,
      color: Color(0xFF9333EA),
    ),
  ];

  void _openUtility(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const CalculatorScreen()),
        );
      case 1:
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const TerminalScreen()));
      case 2:
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const DatabaseOprScreen()));
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
            'Handy tools for your day-to-day work.',
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
                for (final (index, utility) in _utilities.indexed)
                  UtilityCard(
                    title: utility.title,
                    subtitle: utility.subtitle,
                    icon: utility.icon,
                    color: utility.color,
                    onTap: () => _openUtility(index),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
