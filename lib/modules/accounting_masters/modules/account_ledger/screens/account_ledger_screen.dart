import 'package:flutter/material.dart';

import '../state/account_ledger_screen_state.dart';

/// Screen for managing account ledgers.
///
/// The heavy state logic lives in `state/account_ledger_screen_state.dart` so
/// this file stays small (StatefulWidget split pattern).
class AccountLedgerScreen extends StatefulWidget {
  const AccountLedgerScreen({super.key});

  @override
  State<AccountLedgerScreen> createState() => AccountLedgerScreenState();
}