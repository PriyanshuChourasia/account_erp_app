import 'package:flutter/material.dart';

import '../state/address_screen_state.dart';

/// Screen for managing addresses.
///
/// The heavy state logic lives in `state/address_screen_state.dart` so this
/// file stays small (StatefulWidget split pattern).
class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => AddressScreenState();
}
