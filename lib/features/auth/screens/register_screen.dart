import 'package:flutter/material.dart';

import '../state/register_screen_state.dart';

/// Screen for creating a new account.
///
/// Pushed from the login screen; pops with the registered username on success
/// so the login form can prefill it. State lives in
/// `state/register_screen_state.dart` (StatefulWidget split pattern).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => RegisterScreenState();
}
