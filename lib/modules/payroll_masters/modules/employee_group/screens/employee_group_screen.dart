import 'package:flutter/material.dart';

import '../state/employee_group_screen_state.dart';

/// Screen for managing employee groups.
///
/// The heavy state logic lives in `state/employee_group_screen_state.dart`
/// so this file stays small (StatefulWidget split pattern).
class EmployeeGroupScreen extends StatefulWidget {
  const EmployeeGroupScreen({super.key});

  @override
  State<EmployeeGroupScreen> createState() => EmployeeGroupScreenState();
}
