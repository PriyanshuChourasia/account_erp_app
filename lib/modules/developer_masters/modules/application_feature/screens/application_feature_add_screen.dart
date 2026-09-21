import 'package:flutter/material.dart';

import '../state/application_feature_add_screen_state.dart';

/// Screen for creating a new application feature. Pops a
/// `CreateApplicationFeatureRequest` on save. The form is laid out in two
/// grids (Details | Notes), stacked on narrow screens.
///
/// The heavy state logic lives in `state/application_feature_add_screen_state.dart`
/// so this file stays small (StatefulWidget split pattern).
class ApplicationFeatureAddScreen extends StatefulWidget {
  const ApplicationFeatureAddScreen({super.key});

  @override
  State<ApplicationFeatureAddScreen> createState() =>
      ApplicationFeatureAddScreenState();
}