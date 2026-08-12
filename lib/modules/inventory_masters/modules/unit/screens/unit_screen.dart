import 'package:flutter/material.dart';

import '../state/unit_screen_state.dart';

/// Screen for managing units.
///
/// The heavy state logic lives in `state/unit_screen_state.dart` so this file
/// stays small (StatefulWidget split pattern).
class UnitScreen extends StatefulWidget {
  const UnitScreen({super.key});

  @override
  State<UnitScreen> createState() => UnitScreenState();
}
