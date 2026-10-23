import 'package:flutter/material.dart';

import '../state/designation_screen_state.dart';

/// Screen for managing designations.
///
/// The heavy state logic lives in `state/designation_screen_state.dart` so this
/// file stays small (StatefulWidget split pattern).
class DesignationScreen extends StatefulWidget {
  const DesignationScreen({super.key});

  @override
  State<DesignationScreen> createState() => DesignationScreenState();
}
