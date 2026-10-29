import 'package:flutter/material.dart';

import '../modules/stock_category/screens/stock_category_screen.dart';
import '../modules/stock_group/screens/stock_group_screen.dart';
import '../modules/stock_item/screens/stock_item_screen.dart';
import '../modules/unit/screens/unit_screen.dart';
import '../modules/unique_quantity_code/screens/unique_quantity_code_screen.dart';
import '../screens/inventory_masters_screen.dart';
import '../widgets/master_card.dart';

/// State for [InventoryMastersScreen]. Kept out of the screen file to follow
/// the StatefulWidget split pattern.
class InventoryMastersScreenState extends State<InventoryMastersScreen> {
  static const _masters = [
    (
      title: 'Stock Group',
      icon: Icons.folder_special_rounded,
      color: Color(0xFF1D4ED8),
    ),
    (
      title: 'Stock Category',
      icon: Icons.category_rounded,
      color: Color(0xFF059669),
    ),
    (title: 'Unit', icon: Icons.square_foot_rounded, color: Color(0xFFD97706)),
    (title: 'UQC', icon: Icons.straighten_rounded, color: Color(0xFF7C3AED)),
    (
      title: 'Stock Item',
      icon: Icons.inventory_2_rounded,
      color: Color(0xFF059669),
    ),
    // Add more masters here: Location, ...
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
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const UnitScreen()));
      case 3:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const UniqueQuantityCodeScreen(),
          ),
        );
      case 4:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const StockItemScreen()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.extent(
        maxCrossAxisExtent: 130,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: [
          for (final (index, master) in _masters.indexed)
            MasterCard(
              title: master.title,
              icon: master.icon,
              color: master.color,
              onTap: () => _openMaster(index),
            ),
        ],
      ),
    );
  }
}
