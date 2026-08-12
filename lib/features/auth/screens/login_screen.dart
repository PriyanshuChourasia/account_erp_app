import 'package:flutter/material.dart';

import '../state/login_screen_state.dart';

/// Entry screen for signing in.
///
/// The heavy state logic lives in `state/login_screen_state.dart` so this
/// file stays small (StatefulWidget split pattern).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}
