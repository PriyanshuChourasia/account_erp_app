import 'package:flutter/material.dart';

import '../modules/bank/screens/bank_screen.dart';
import '../modules/bank_branch/screens/bank_branch_screen.dart';
import '../modules/bank_type/screens/bank_type_screen.dart';
import '../modules/blood_group/screens/blood_group_screen.dart';
import '../modules/calculator/screens/calculator_screen.dart';
import '../modules/database_opr/screens/database_opr_screen.dart';
import '../modules/gender/screens/gender_screen.dart';
import '../modules/terminal/screens/terminal_screen.dart';
import '../screens/utility_screen.dart';
import '../widgets/utility_card.dart';

/// State for [UtilityScreen]. Kept out of the screen file to follow the
/// StatefulWidget split pattern.
class UtilityScreenState extends State<UtilityScreen> {
  static const _utilities = [
    (
      title: 'Bank Types',
      icon: Icons.category_outlined,
      color: Color(0xFF1D4ED8),
    ),
    (
      title: 'Banks',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF059669),
    ),
    (
      title: 'Bank Branches',
      icon: Icons.store_mall_directory_rounded,
      color: Color(0xFF7C3AED),
    ),
    (title: 'Blood Groups', icon: Icons.bloodtype, color: Color(0xFFDC2626)),
    (title: 'Genders', icon: Icons.wc_rounded, color: Color(0xFFDB2777)),
    (
      title: 'Calculator',
      icon: Icons.calculate_rounded,
      color: Color(0xFF1D4ED8),
    ),
    (title: 'Terminal', icon: Icons.terminal_rounded, color: Color(0xFF0D9488)),
    (
      title: 'Database Operations',
      icon: Icons.storage_rounded,
      color: Color(0xFF9333EA),
    ),
  ];

  void _openUtility(int index) {
    final Widget screen = switch (index) {
      0 => const BankTypeScreen(),
      1 => const BankScreen(),
      2 => const BankBranchScreen(),
      3 => const BloodGroupScreen(),
      4 => const GenderScreen(),
      5 => const CalculatorScreen(),
      6 => const TerminalScreen(),
      _ => const DatabaseOprScreen(),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
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
          for (final (index, utility) in _utilities.indexed)
            UtilityCard(
              title: utility.title,
              icon: utility.icon,
              color: utility.color,
              onTap: () => _openUtility(index),
            ),
        ],
      ),
    );
  }
}
