import 'package:flutter/material.dart';

import '../state/department_add_screen_state.dart';

/// Screen for creating a new department. Pops a `CreateDepartmentRequest` on save.
///
/// The heavy state logic lives in `state/department_add_screen_state.dart` so
/// this file stays small (StatefulWidget split pattern).
class DepartmentAddScreen extends StatefulWidget {
  const DepartmentAddScreen({super.key});

  @override
  State<DepartmentAddScreen> createState() => DepartmentAddScreenState();
}
