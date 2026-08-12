import 'package:flutter/material.dart';

import '../state/account_nature_screen_state.dart';

/// Screen for managing account natures.
///
/// The heavy state logic lives in `state/account_nature_screen_state.dart` so
/// this file stays small (StatefulWidget split pattern).
class AccountNatureScreen extends StatefulWidget {
  const AccountNatureScreen({super.key});

  @override
  State<AccountNatureScreen> createState() => AccountNatureScreenState();
}
