import 'package:flutter/material.dart';

import '../state/stock_category_screen_state.dart';

/// Screen for managing stock categories.
///
/// The heavy state logic lives in `state/stock_category_screen_state.dart` so
/// this file stays small (StatefulWidget split pattern).
class StockCategoryScreen extends StatefulWidget {
  const StockCategoryScreen({super.key});

  @override
  State<StockCategoryScreen> createState() => StockCategoryScreenState();
}
