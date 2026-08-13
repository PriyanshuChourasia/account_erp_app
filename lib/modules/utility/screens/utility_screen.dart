import 'package:flutter/material.dart';

import '../state/utility_screen_state.dart';

/// Index screen listing the available utility tools.
///
/// The heavy state logic lives in `state/utility_screen_state.dart` so this
/// file stays small (StatefulWidget split pattern).
class UtilityScreen extends StatefulWidget {
  const UtilityScreen({super.key});

  @override
  State<UtilityScreen> createState() => UtilityScreenState();
}
