import 'package:flutter/material.dart';

import '../state/payroll_masters_screen_state.dart';

/// Index screen listing the payroll masters.
///
/// The heavy state logic lives in `state/payroll_masters_screen_state.dart`
/// so this file stays small (StatefulWidget split pattern).
class PayrollMastersScreen extends StatefulWidget {
  const PayrollMastersScreen({super.key});

  @override
  State<PayrollMastersScreen> createState() => PayrollMastersScreenState();
}
