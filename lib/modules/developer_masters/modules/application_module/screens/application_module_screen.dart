import 'package:flutter/material.dart';

import '../state/application_module_screen_state.dart';

/// Screen for managing application modules.
///
/// The heavy state logic lives in
/// `state/application_module_screen_state.dart` so this file stays small
/// (StatefulWidget split pattern).
class ApplicationModuleScreen extends StatefulWidget {
  const ApplicationModuleScreen({super.key});

  @override
  State<ApplicationModuleScreen> createState() =>
      ApplicationModuleScreenState();
}
