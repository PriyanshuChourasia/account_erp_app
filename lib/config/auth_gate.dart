import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/auth/viewModel/auth_view_model.dart';
import '../features/dashboard/screens/dashboard_screen.dart';

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
  @override
  void initState() {
    super.initState();
    // Deferred so we don't notify during the first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthViewModel>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    if (viewModel.isCheckingSession) return const _SplashScreen();
    return viewModel.isAuthenticated
        ? DashboardScreen(
            userName: viewModel.user?.name,
            onLogout: viewModel.logout,
          )
        : const LoginScreen();
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_rounded,
              size: 64,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Account ERP',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}
