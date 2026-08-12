import 'package:flutter/material.dart';

import '../state/item_screen_state.dart';

/// Catalogue screen for managing items.
///
/// The heavy state logic lives in `state/item_screen_state.dart` so this
/// file stays small (StatefulWidget split pattern).
class ItemScreen extends StatefulWidget {
  const ItemScreen({super.key});

  @override
  State<ItemScreen> createState() => ItemScreenState();
}
