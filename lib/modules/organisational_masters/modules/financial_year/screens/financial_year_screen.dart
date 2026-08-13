import 'package:flutter/material.dart';

import '../state/financial_year_screen_state.dart';

/// Screen for managing financial years.
///
/// The heavy state logic lives in `state/financial_year_screen_state.dart`
/// so this file stays small (StatefulWidget split pattern).
class FinancialYearScreen extends StatefulWidget {
  const FinancialYearScreen({super.key});

  @override
  State<FinancialYearScreen> createState() => FinancialYearScreenState();
}
