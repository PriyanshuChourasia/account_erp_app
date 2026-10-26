import 'package:flutter/material.dart';

import '../state/blood_group_screen_state.dart';

/// Screen for managing blood groups.
///
/// The heavy state logic lives in `state/blood_group_screen_state.dart` so this
/// file stays small (StatefulWidget split pattern).
class BloodGroupScreen extends StatefulWidget {
  const BloodGroupScreen({super.key});

  @override
  State<BloodGroupScreen> createState() => BloodGroupScreenState();
}
