import 'package:flutter/material.dart';

import '../state/company_add_screen_state.dart';

/// Screen for creating a new company. Pops a `CreateCompanyRequest` on save.
///
/// The heavy state logic lives in `state/company_add_screen_state.dart` so
/// this file stays small (StatefulWidget split pattern).
class CompanyAddScreen extends StatefulWidget {
  const CompanyAddScreen({super.key});

  @override
  State<CompanyAddScreen> createState() => CompanyAddScreenState();
}
