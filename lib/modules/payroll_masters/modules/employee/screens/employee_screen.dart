import 'package:flutter/material.dart';

import '../state/employee_screen_state.dart';

/// Screen for managing employees.
///
/// The heavy state logic lives in `state/employee_screen_state.dart` so this
/// file stays small (StatefulWidget split pattern).
class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => EmployeeScreenState();
}
