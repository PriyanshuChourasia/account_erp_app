import 'package:flutter/material.dart';

import '../state/dashboard_screen_state.dart';

/// Home screen shown after a successful sign-in.
///
/// Receives the signed-in user's name and a logout callback from the
/// [AuthGate] composition root, so the dashboard never depends on the auth
/// feature's internals (feature isolation).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.userName, this.onLogout});

  final String? userName;
  final VoidCallback? onLogout;

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}
