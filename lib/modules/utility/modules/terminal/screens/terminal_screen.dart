import 'package:flutter/material.dart';

import '../state/terminal_screen_state.dart';

/// Screen for a simulated command-line terminal.
///
/// The heavy state logic lives in `state/terminal_screen_state.dart` so this
/// file stays small (StatefulWidget split pattern).
class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => TerminalScreenState();
}
