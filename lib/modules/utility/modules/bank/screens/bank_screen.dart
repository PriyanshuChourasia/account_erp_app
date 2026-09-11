import 'package:flutter/material.dart';

import '../state/bank_screen_state.dart';

/// Screen for managing banks.
///
/// The heavy state logic lives in `state/bank_screen_state.dart` so this file
/// stays small (StatefulWidget split pattern).
class BankScreen extends StatefulWidget {
  const BankScreen({super.key});

  @override
  State<BankScreen> createState() => BankScreenState();
}