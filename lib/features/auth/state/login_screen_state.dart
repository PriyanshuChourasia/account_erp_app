import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/app_theme.dart';
import '../../../core/handlers/error_handler.dart';
import '../../../routing/app_routes.dart';
import '../screens/login_screen.dart';
import '../viewModel/auth_view_model.dart';
import '../widgets/auth_header.dart';
import '../widgets/features_panel.dart';
import '../widgets/primary_button.dart';

/// State for [LoginScreen]. Kept out of the screen file to follow the
/// StatefulWidget split pattern.
class LoginScreenState extends State<LoginScreen> {
  final _signInFormKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  /// Breakpoint at which the layout switches from stacked to side-by-side.
  static const double _wideBreakpoint = 860;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Submit handler ─────────────────────────────────────────────────────

  Future<void> _submitSignIn() async {
    FocusScope.of(context).unfocus();
    if (!(_signInFormKey.currentState?.validate() ?? false)) return;

    final viewModel = context.read<AuthViewModel>();
    final success = await viewModel.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.gatewayOfAccounts);
    } else if (mounted) {
      ErrorHandler.showError(
        context,
        viewModel.error ?? 'Login failed. Please try again.',
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isWide = screenWidth >= _wideBreakpoint;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: isWide
          ? Row(
              children: [
                const Expanded(flex: 2, child: FeaturesPanel()),
                Expanded(flex: 3, child: Center(child: _buildSignInPanel())),
              ],
            )
          : SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthHeader(),
                    Transform.translate(
                      offset: const Offset(0, -28),
                      child: Center(child: _buildSignInPanel()),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSignInPanel() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Card(
            elevation: 4,
            shadowColor: Colors.black.withValues(alpha: 0.15),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: _SignInForm(
                formKey: _signInFormKey,
                usernameController: _usernameController,
                passwordController: _passwordController,
                obscurePassword: _obscurePassword,
                viewModel: context.watch<AuthViewModel>(),
                onSubmit: _submitSignIn,
                onTogglePassword: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Sign In form
// ═══════════════════════════════════════════════════════════════════════════

class _SignInForm extends StatelessWidget {
  const _SignInForm({
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.viewModel,
    required this.onSubmit,
    required this.onTogglePassword,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final dynamic viewModel;
  final VoidCallback onSubmit;
  final VoidCallback onTogglePassword;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome back',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to your Account ERP workspace',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: usernameController,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            decoration: const InputDecoration(
              labelText: 'Username',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter your username' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onFieldSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: obscurePassword ? 'Show password' : 'Hide password',
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: onTogglePassword,
              ),
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Enter your password' : null,
          ),
          const SizedBox(height: 28),
          AnimatedBuilder(
            animation: Listenable.merge([
              usernameController,
              passwordController,
            ]),
            builder: (context, _) {
              final hasInput =
                  usernameController.text.trim().isNotEmpty &&
                  passwordController.text.isNotEmpty;
              return PrimaryButton(
                label: 'Sign in',
                icon: Icons.login_rounded,
                loading: viewModel.isLoading,
                onPressed: (viewModel.isLoading || !hasInput) ? null : onSubmit,
              );
            },
          ),
        ],
      ),
    );
  }
}
