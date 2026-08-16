import 'package:flutter/material.dart';

import '../state/unique_quantity_code_screen_state.dart';

/// Screen for managing UQCs (Unit Quantity Codes).
///
/// The heavy state logic lives in `state/unique_quantity_code_screen_state.dart` so this file
/// stays small (StatefulWidget split pattern).
class UniqueQuantityCodeScreen extends StatefulWidget {
  const UniqueQuantityCodeScreen({super.key});

  @override
  State<UniqueQuantityCodeScreen> createState() =>
      UniqueQuantityCodeScreenState();
}
