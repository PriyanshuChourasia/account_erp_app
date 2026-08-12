import 'package:flutter/material.dart';

import '../state/organisational_masters_screen_state.dart';

/// Index screen listing the organisational masters.
///
/// The heavy state logic lives in `state/organisational_masters_screen_state.dart`
/// so this file stays small (StatefulWidget split pattern).
class OrganisationalMastersScreen extends StatefulWidget {
  const OrganisationalMastersScreen({super.key});

  @override
  State<OrganisationalMastersScreen> createState() =>
      OrganisationalMastersScreenState();
}
