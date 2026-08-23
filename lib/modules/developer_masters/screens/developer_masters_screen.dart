import 'package:flutter/material.dart';

import '../state/developer_masters_screen_state.dart';

/// Index/dashboard screen for the developer masters domain.
///
/// The heavy state logic lives in `state/developer_masters_screen_state.dart`
/// so this file stays small (StatefulWidget split pattern).
class DeveloperMastersScreen extends StatefulWidget {
  const DeveloperMastersScreen({super.key});

  @override
  State<DeveloperMastersScreen> createState() =>
      DeveloperMastersScreenState();
}
