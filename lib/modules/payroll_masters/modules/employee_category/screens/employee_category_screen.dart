import 'package:flutter/material.dart';

import '../state/employee_category_screen_state.dart';

/// Screen for managing employee categories.
///
/// The heavy state logic lives in `state/employee_category_screen_state.dart`
/// so this file stays small (StatefulWidget split pattern).
class EmployeeCategoryScreen extends StatefulWidget {
  const EmployeeCategoryScreen({super.key});

  @override
  State<EmployeeCategoryScreen> createState() => EmployeeCategoryScreenState();
}
