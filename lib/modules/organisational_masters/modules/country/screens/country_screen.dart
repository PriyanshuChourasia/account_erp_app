import 'package:flutter/material.dart';

import '../state/country_screen_state.dart';

/// Screen for managing countries.
///
/// The heavy state logic lives in `state/country_screen_state.dart` so this
/// file stays small (StatefulWidget split pattern).
class CountryScreen extends StatefulWidget {
  const CountryScreen({super.key});

  @override
  State<CountryScreen> createState() => CountryScreenState();
}
