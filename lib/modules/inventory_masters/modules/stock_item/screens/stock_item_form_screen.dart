import 'package:flutter/material.dart';

import '../state/stock_item_form_screen_state.dart';

/// Full-screen multi-step form for creating a new stock item.
///
/// Opened as a route (e.g. via
/// `Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StockItemFormScreen()))`)
/// and popped with no result once the item has been created; the caller is
/// responsible for calling the stock item view model's `addStockItem`.
class StockItemFormScreen extends StatefulWidget {
  const StockItemFormScreen({super.key});

  @override
  State<StockItemFormScreen> createState() => StockItemFormScreenState();
}
