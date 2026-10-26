import 'package:flutter/material.dart';

import '../state/gender_screen_state.dart';

/// Screen for managing genders.
///
/// The heavy state logic lives in `state/gender_screen_state.dart` so this
/// file stays small (StatefulWidget split pattern).
class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => GenderScreenState();
}
