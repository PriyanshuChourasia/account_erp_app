import 'package:flutter/material.dart';

import '../state/company_screen_state.dart';

/// Screen for managing companies.
///
/// The heavy state logic lives in `state/company_screen_state.dart` so this
/// file stays small (StatefulWidget split pattern).
class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key});

  @override
  State<CompanyScreen> createState() => CompanyScreenState();
}
