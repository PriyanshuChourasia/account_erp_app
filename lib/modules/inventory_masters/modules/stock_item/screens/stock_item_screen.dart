import 'package:flutter/material.dart';

import '../state/stock_item_screen_state.dart';

/// Screen for managing stock items.
///
/// The heavy state logic lives in `state/stock_item_screen_state.dart` so
/// this file stays small (StatefulWidget split pattern).
class StockItemScreen extends StatefulWidget {
  const StockItemScreen({super.key});

  @override
  State<StockItemScreen> createState() => StockItemScreenState();
}
