import 'package:flutter/material.dart';

import '../state/api_operation_screen_state.dart';

/// Screen for API operations.
///
/// The heavy state logic lives in `state/api_operation_screen_state.dart` so
/// this file stays small (StatefulWidget split pattern).
class ApiOperationScreen extends StatefulWidget {
  const ApiOperationScreen({super.key});

  @override
  State<ApiOperationScreen> createState() => ApiOperationScreenState();
}