import 'package:flutter/material.dart';

import '../state/database_opr_screen_state.dart';

/// Screen for database operations.
///
/// The heavy state logic lives in `state/database_opr_screen_state.dart` so
/// this file stays small (StatefulWidget split pattern).
class DatabaseOprScreen extends StatefulWidget {
  const DatabaseOprScreen({super.key});

  @override
  State<DatabaseOprScreen> createState() => DatabaseOprScreenState();
}