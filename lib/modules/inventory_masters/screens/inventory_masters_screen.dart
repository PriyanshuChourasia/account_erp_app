import 'package:flutter/material.dart';

import '../state/inventory_masters_screen_state.dart';

/// Index screen listing the inventory masters.
///
/// The heavy state logic lives in `state/inventory_masters_screen_state.dart`
/// so this file stays small (StatefulWidget split pattern).
class InventoryMastersScreen extends StatefulWidget {
  const InventoryMastersScreen({super.key});

  @override
  State<InventoryMastersScreen> createState() => InventoryMastersScreenState();
}
