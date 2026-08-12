import 'package:flutter/material.dart';

import '../state/account_group_screen_state.dart';

/// Screen for managing accounting groups.
///
/// The heavy state logic lives in `state/account_group_screen_state.dart`
/// so this file stays small (StatefulWidget split pattern).
class AccountGroupScreen extends StatefulWidget {
  const AccountGroupScreen({super.key});

  @override
  State<AccountGroupScreen> createState() => AccountGroupScreenState();
}
