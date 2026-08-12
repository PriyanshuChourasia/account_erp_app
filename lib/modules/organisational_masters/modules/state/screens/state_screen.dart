import 'package:flutter/material.dart';

import '../state/state_screen_state.dart';

/// Screen for managing states.
///
/// The heavy state logic lives in `state/state_screen_state.dart` so this file
/// stays small (StatefulWidget split pattern).
class StateScreen extends StatefulWidget {
  const StateScreen({super.key});

  @override
  State<StateScreen> createState() => StateScreenState();
}
