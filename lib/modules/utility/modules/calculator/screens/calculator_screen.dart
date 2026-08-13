import 'package:flutter/material.dart';

import '../state/calculator_screen_state.dart';

/// Screen for performing quick arithmetic.
///
/// The heavy state logic lives in `state/calculator_screen_state.dart` so this
/// file stays small (StatefulWidget split pattern).
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => CalculatorScreenState();
}
