import 'package:flutter/material.dart';

import '../state/designation_add_screen_state.dart';

/// Screen for creating a new designation. Pops a `CreateDesignationRequest` on save.
///
/// The heavy state logic lives in `state/designation_add_screen_state.dart` so
/// this file stays small (StatefulWidget split pattern).
class DesignationAddScreen extends StatefulWidget {
  const DesignationAddScreen({super.key});

  @override
  State<DesignationAddScreen> createState() => DesignationAddScreenState();
}
