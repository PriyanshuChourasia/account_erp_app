import 'package:flutter/material.dart';

import '../state/department_screen_state.dart';

/// Screen for managing departments.
///
/// The heavy state logic lives in `state/department_screen_state.dart` so this
/// file stays small (StatefulWidget split pattern).
class DepartmentScreen extends StatefulWidget {
  const DepartmentScreen({super.key});

  @override
  State<DepartmentScreen> createState() => DepartmentScreenState();
}
