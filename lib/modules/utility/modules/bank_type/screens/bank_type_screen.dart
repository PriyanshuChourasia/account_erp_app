import 'package:flutter/material.dart';

import '../state/bank_type_screen_state.dart';

/// Screen for managing bank types.
///
/// The heavy state logic lives in `state/bank_type_screen_state.dart` so this
/// file stays small (StatefulWidget split pattern).
class BankTypeScreen extends StatefulWidget {
  const BankTypeScreen({super.key});

  @override
  State<BankTypeScreen> createState() => BankTypeScreenState();
}