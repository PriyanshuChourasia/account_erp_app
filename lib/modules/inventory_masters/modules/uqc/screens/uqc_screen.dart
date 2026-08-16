import 'package:flutter/material.dart';

import '../state/uqc_screen_state.dart';

/// Screen for managing UQCs (Unit Quantity Codes).
///
/// The heavy state logic lives in `state/uqc_screen_state.dart` so this file
/// stays small (StatefulWidget split pattern).
class UqcScreen extends StatefulWidget {
  const UqcScreen({super.key});

  @override
  State<UqcScreen> createState() => UqcScreenState();
}
