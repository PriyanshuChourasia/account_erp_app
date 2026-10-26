import 'package:flutter/material.dart';

import '../modules/employee/screens/employee_screen.dart';
import '../modules/employee_category/screens/employee_category_screen.dart';
import '../modules/employee_group/screens/employee_group_screen.dart';
import '../screens/payroll_masters_screen.dart';
import '../widgets/master_card.dart';

/// State for [PayrollMastersScreen]. Kept out of the screen file to follow
/// the StatefulWidget split pattern.
class PayrollMastersScreenState extends State<PayrollMastersScreen> {
  static const _masters = [
    (title: 'Employee', icon: Icons.person_rounded, color: Color(0xFF1D4ED8)),
    (
      title: 'Employee Group',
      icon: Icons.groups_rounded,
      color: Color(0xFF059669),
    ),
    (
      title: 'Employee Category',
      icon: Icons.category_rounded,
      color: Color(0xFF7C3AED),
    ),
  ];

  void _openMaster(int index) {
    switch (index) {
      case 0:
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const EmployeeScreen()));
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const EmployeeGroupScreen()),
        );
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const EmployeeCategoryScreen(),
          ),
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
