import 'package:flutter/material.dart';

import '../../../../config/theme/app_theme.dart';
import '../modules/account_nature/screens/account_nature_screen.dart';
import '../modules/account_group/screens/account_group_screen.dart';
import '../screens/accounting_masters_screen.dart';
import '../widgets/master_card.dart';

/// State for [AccountingMastersScreen]. Kept out of the screen file to follow
/// the StatefulWidget split pattern.
class AccountingMastersScreenState extends State<AccountingMastersScreen> {
  static const _masters = [
    (
      title: 'Account Group',
      subtitle: 'Group ledgers under assets, liabilities, income & expenses',
      icon: Icons.account_tree_rounded,
      color: Color(0xFF7C3AED),
    ),
    (
      title: 'Account Nature',
      subtitle: 'Classify accounts by their nature',
      icon: Icons.category_rounded,
      color: Color(0xFF0D9488),
    ),
    // Add more masters here: Ledger, Voucher Type, ...
  ];

  void _openMaster(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AccountGroupScreen()),
        );
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AccountNatureScreen()),
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
            'Manage your accounting master data.',
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
