import 'package:flutter/material.dart';

import '../state/stock_group_screen_state.dart';

/// Screen for managing stock groups.
///
/// The heavy state logic lives in `state/stock_group_screen_state.dart` so
/// this file stays small (StatefulWidget split pattern).
class StockGroupScreen extends StatefulWidget {
  const StockGroupScreen({super.key});

  @override
  State<StockGroupScreen> createState() => StockGroupScreenState();
}
