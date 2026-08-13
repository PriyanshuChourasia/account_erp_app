import 'package:flutter/material.dart';

import '../../../../config/theme/app_theme.dart';
import '../modules/country/screens/country_screen.dart';
import '../modules/financial_year/screens/financial_year_screen.dart';
import '../modules/state/screens/state_screen.dart';
import '../screens/organisational_masters_screen.dart';
import '../widgets/master_card.dart';

/// State for [OrganisationalMastersScreen]. Kept out of the screen file to
/// follow the StatefulWidget split pattern.
class OrganisationalMastersScreenState extends State<OrganisationalMastersScreen> {
  static const _masters = [
    (
      title: 'Country',
      subtitle: 'Maintain the list of countries',
      icon: Icons.public_rounded,
      color: Color(0xFF0D9488),
    ),
    (
      title: 'State',
      subtitle: 'Maintain states and regions under each country',
      icon: Icons.map_rounded,
      color: Color(0xFF1D4ED8),
    ),
    (
      title: 'Financial Year',
      subtitle: 'Maintain fiscal years for accounting transactions',
      icon: Icons.calendar_month_rounded,
      color: Color(0xFF7C3AED),
    ),
    // Add more masters here: District, City, ...
  ];

  void _openMaster(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const CountryScreen()),
        );
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const StateScreen()),
        );
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const FinancialYearScreen()),
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
            'Manage your organisational master data.',
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
