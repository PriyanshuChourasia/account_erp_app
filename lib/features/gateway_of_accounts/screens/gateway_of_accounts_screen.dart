import 'package:flutter/material.dart';

import '../state/gateway_of_accounts_screen_state.dart';

/// Landing screen shown immediately after a successful registration.
///
/// Presents the newly registered user with options to set up or join an
/// account workspace. State lives in
/// `state/gateway_of_accounts_screen_state.dart` (StatefulWidget split pattern).
class GatewayOfAccountsScreen extends StatefulWidget {
  const GatewayOfAccountsScreen({super.key});

  @override
  State<GatewayOfAccountsScreen> createState() =>
      GatewayOfAccountsScreenState();
}
