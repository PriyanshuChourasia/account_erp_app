import 'package:flutter/material.dart';

import '../state/application_feature_screen_state.dart';

/// Screen for managing application features.
///
/// The heavy state logic lives in
/// `state/application_feature_screen_state.dart` so this file stays small
/// (StatefulWidget split pattern).
class ApplicationFeatureScreen extends StatefulWidget {
  const ApplicationFeatureScreen({super.key});

  @override
  State<ApplicationFeatureScreen> createState() =>
      ApplicationFeatureScreenState();
}
