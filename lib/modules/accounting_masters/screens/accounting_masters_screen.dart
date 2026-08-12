import 'package:flutter/material.dart';

import '../state/accounting_masters_screen_state.dart';

/// Index screen listing the accounting masters.
///
/// The heavy state logic lives in `state/accounting_masters_screen_state.dart`
/// so this file stays small (StatefulWidget split pattern).
class AccountingMastersScreen extends StatefulWidget {
  const AccountingMastersScreen({super.key});

  @override
  State<AccountingMastersScreen> createState() =>
      AccountingMastersScreenState();
}
