import 'package:flutter/material.dart';

import '../modules/account_nature/screens/account_nature_screen.dart';
import '../modules/account_group/screens/account_group_screen.dart';
import '../modules/account_ledger/screens/account_ledger_screen.dart';
import '../modules/voucher_type/screens/voucher_type_screen.dart';
import '../screens/accounting_masters_screen.dart';
import '../widgets/master_card.dart';

/// State for [AccountingMastersScreen]. Kept out of the screen file to follow
/// the StatefulWidget split pattern.
class AccountingMastersScreenState extends State<AccountingMastersScreen> {
  static const _masters = [
    (
      title: 'Account Group',
      icon: Icons.account_tree_rounded,
      color: Color(0xFF7C3AED),
    ),
    (
      title: 'Account Nature',
      icon: Icons.category_rounded,
      color: Color(0xFF0D9488),
    ),
    (
      title: 'Voucher Type',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFF1D4ED8),
    ),
    (
      title: 'Account Ledger',
      icon: Icons.menu_book_rounded,
      color: Color(0xFFD97706),
    ),
    // Add more masters here.
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
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const VoucherTypeScreen()),
        );
      case 3:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AccountLedgerScreen()),
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
