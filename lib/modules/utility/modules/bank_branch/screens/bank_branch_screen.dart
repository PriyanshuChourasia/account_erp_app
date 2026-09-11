import 'package:flutter/material.dart';

import '../state/bank_branch_screen_state.dart';

/// Screen for managing bank branches.
///
/// The heavy state logic lives in `state/bank_branch_screen_state.dart` so this
/// file stays small (StatefulWidget split pattern).
class BankBranchScreen extends StatefulWidget {
  const BankBranchScreen({super.key});

  @override
  State<BankBranchScreen> createState() => BankBranchScreenState();
}