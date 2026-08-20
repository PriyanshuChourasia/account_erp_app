import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/auth/viewModel/auth_view_model.dart';
import '../features/gateway_of_accounts/screens/gateway_of_accounts_screen.dart';
import '../features/splash/screens/splash_screen.dart';

/// Decides the entry screen based on the auth state.
///
/// This is the `home` of the app. It never performs navigation itself — it
/// simply swaps the widget tree when the [AuthViewModel] notifies.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  static const _minSplashDuration = Duration(seconds: 2);

  bool _minSplashElapsed = false;

  @override
  void initState() {
    super.initState();
    // Deferred so we don't notify during the first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthViewModel>().checkAuthStatus();
    });
    Future.delayed(_minSplashDuration, () {
      if (mounted) setState(() => _minSplashElapsed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    if (viewModel.isCheckingSession || !_minSplashElapsed) {
      return const SplashScreen();
    }
    return viewModel.isAuthenticated
        ? const GatewayOfAccountsScreen()
        : const LoginScreen();
  }
}
