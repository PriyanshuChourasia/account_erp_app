import 'package:flutter/material.dart';

import '../../../../config/theme/app_theme.dart';
import '../modules/stock_category/screens/stock_category_screen.dart';
import '../modules/stock_group/screens/stock_group_screen.dart';
import '../modules/unit/screens/unit_screen.dart';
import '../screens/inventory_masters_screen.dart';
import '../widgets/master_card.dart';

/// State for [InventoryMastersScreen]. Kept out of the screen file to follow
/// the StatefulWidget split pattern.
class InventoryMastersScreenState extends State<InventoryMastersScreen> {
  static const _masters = [
    (
      title: 'Stock Group',
      subtitle: 'Classify inventory items into groups',
      icon: Icons.folder_special_rounded,
      color: Color(0xFF1D4ED8),
    ),
    (
      title: 'Stock Category',
      subtitle: 'Categorise inventory items',
      icon: Icons.category_rounded,
      color: Color(0xFF059669),
    ),
    (
      title: 'Unit',
      subtitle: 'Units of measurement for items',
      icon: Icons.square_foot_rounded,
      color: Color(0xFFD97706),
    ),
    // Add more masters here: Item, Location, ...
  ];

  void _openMaster(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const StockGroupScreen()),
        );
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const StockCategoryScreen()),
        );
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const UnitScreen()),
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
            'Manage your inventory master data.',
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
