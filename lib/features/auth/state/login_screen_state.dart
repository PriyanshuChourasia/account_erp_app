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
  final _registerFormKey = GlobalKey<FormState>();
  final _licenseController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerContactController = TextEditingController();
  final _registerCountryCodeController = TextEditingController(text: '+91');
  final _registerAltContactController = TextEditingController();
  final _registerDobController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureRegPassword = true;
  bool _obscureRegConfirm = true;
  DateTime? _registerSelectedDate;

  /// Current auth tab: 0 = License, 1 = Sign In, 2 = Register.
  int _authTab = 0;

  /// Breakpoint at which the layout switches from stacked to side-by-side.
  static const double _wideBreakpoint = 860;

  @override
  void dispose() {
    _licenseController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerContactController.dispose();
    _registerCountryCodeController.dispose();
    _registerAltContactController.dispose();
    _registerDobController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmController.dispose();
    super.dispose();
  }

  // ── Submit handlers ────────────────────────────────────────────────────

  Future<void> _submitLicense() async {
    FocusScope.of(context).unfocus();
    if (_licenseController.text.trim().isEmpty) return;
    // TODO: Validate license against API, then move to sign-in.
    setState(() => _authTab = 1);
  }

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

  Future<void> _submitRegister() async {
    FocusScope.of(context).unfocus();
    if (!(_registerFormKey.currentState?.validate() ?? false)) return;

    final viewModel = context.read<AuthViewModel>();
    final contactNoText = _registerContactController.text.trim();
    final altContactNoText = _registerAltContactController.text.trim();

    final success = await viewModel.register(
      name: _registerNameController.text.trim(),
      email: _registerEmailController.text.trim(),
      password: _registerPasswordController.text,
      contactNo: int.parse(contactNoText),
      countryCode: _registerCountryCodeController.text.trim(),
      altContactNo: altContactNoText.isNotEmpty
          ? int.parse(altContactNoText)
          : null,
      dateOfBirth: _registerDobController.text.isNotEmpty
          ? _registerDobController.text
          : null,
    );

    if (!success) {
      if (mounted) {
        ErrorHandler.showError(
          context,
          viewModel.error ?? 'Registration failed. Please try again.',
        );
      }
      return;
    }

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.gatewayOfAccounts);
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
                Expanded(flex: 3, child: Center(child: _buildRightPanel())),
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
                      child: Center(child: _buildRightPanel()),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  /// Right panel: tabbed auth (license / sign in / register).
  Widget _buildRightPanel() => _buildAuthPanel();

  // ── Tabbed Auth Panel ──────────────────────────────────────────────────

  Widget _buildAuthPanel() {
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Tab bar ──
                  _AuthTabBar(
                    selected: _authTab,
                    onTabChanged: (i) => setState(() => _authTab = i),
                  ),
                  const SizedBox(height: 28),

                  // ── Tab content ──
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildTabContent(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_authTab) {
      case 0:
        return _LicenseTab(
          key: const ValueKey('license'),
          controller: _licenseController,
          onSubmit: _submitLicense,
          onSwitchToSignIn: () => setState(() => _authTab = 1),
        );
      case 1:
        return _SignInTab(
          key: const ValueKey('signin'),
          formKey: _signInFormKey,
          usernameController: _usernameController,
          passwordController: _passwordController,
          obscurePassword: _obscurePassword,
          viewModel: context.watch<AuthViewModel>(),
          onSubmit: _submitSignIn,
          onTogglePassword: () =>
              setState(() => _obscurePassword = !_obscurePassword),
          onSwitchToRegister: () => setState(() => _authTab = 2),
        );
      case 2:
        return _RegisterTab(
          key: const ValueKey('register'),
          formKey: _registerFormKey,
          nameController: _registerNameController,
          emailController: _registerEmailController,
          contactController: _registerContactController,
          countryCodeController: _registerCountryCodeController,
          altContactController: _registerAltContactController,
          dobController: _registerDobController,
          passwordController: _registerPasswordController,
          confirmController: _registerConfirmController,
          obscurePassword: _obscureRegPassword,
          obscureConfirm: _obscureRegConfirm,
          selectedDate: _registerSelectedDate,
          onSubmit: _submitRegister,
          onTogglePassword: () =>
              setState(() => _obscureRegPassword = !_obscureRegPassword),
          onToggleConfirm: () =>
              setState(() => _obscureRegConfirm = !_obscureRegConfirm),
          onDatePicked: (date) => setState(() => _registerSelectedDate = date),
          onSwitchToSignIn: () => setState(() => _authTab = 1),
        );
      default:
        return const SizedBox.shrink();
    }
  }

}

// ═══════════════════════════════════════════════════════════════════════════
// Tab Bar
// ═══════════════════════════════════════════════════════════════════════════

class _AuthTabBar extends StatelessWidget {
  const _AuthTabBar({required this.selected, required this.onTabChanged});

  final int selected;
  final ValueChanged<int> onTabChanged;

  static const _labels = ['License', 'Sign In', 'Register'];
  static const _icons = [
    Icons.badge_outlined,
    Icons.login_rounded,
    Icons.person_add_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = selected == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _icons[i],
                      size: 16,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _labels[i],
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Tab 0: License
// ═══════════════════════════════════════════════════════════════════════════

class _LicenseTab extends StatelessWidget {
  const _LicenseTab({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.onSwitchToSignIn,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback onSwitchToSignIn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Enter your license',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Provide your license number to access your workspace.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: controller,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => onSubmit(),
          decoration: const InputDecoration(
            labelText: 'License Number',
            prefixIcon: Icon(Icons.badge_outlined),
            hintText: 'e.g. LIC-2025-001',
          ),
        ),
        const SizedBox(height: 24),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) => PrimaryButton(
            label: 'Continue',
            icon: Icons.arrow_forward_rounded,
            onPressed: value.text.trim().isEmpty ? null : onSubmit,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                'No license?',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: onSwitchToSignIn,
              child: const Text('Sign in directly'),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Tab 1: Sign In
// ═══════════════════════════════════════════════════════════════════════════

class _SignInTab extends StatelessWidget {
  const _SignInTab({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.viewModel,
    required this.onSubmit,
    required this.onTogglePassword,
    required this.onSwitchToRegister,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final dynamic viewModel;
  final VoidCallback onSubmit;
  final VoidCallback onTogglePassword;
  final VoidCallback onSwitchToRegister;

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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  "Don't have an account?",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: onSwitchToRegister,
                child: const Text('Create one'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Tab 2: Register
// ═══════════════════════════════════════════════════════════════════════════

class _RegisterTab extends StatelessWidget {
  const _RegisterTab({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.contactController,
    required this.countryCodeController,
    required this.altContactController,
    required this.dobController,
    required this.passwordController,
    required this.confirmController,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.selectedDate,
    required this.onSubmit,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onDatePicked,
    required this.onSwitchToSignIn,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController contactController;
  final TextEditingController countryCodeController;
  final TextEditingController altContactController;
  final TextEditingController dobController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool obscurePassword;
  final bool obscureConfirm;
  final DateTime? selectedDate;
  final VoidCallback onSubmit;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final ValueChanged<DateTime> onDatePicked;
  final VoidCallback onSwitchToSignIn;

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked == null) return;
    dobController.text =
        '${picked.year.toString().padLeft(4, '0')}-'
        '${picked.month.toString().padLeft(2, '0')}-'
        '${picked.day.toString().padLeft(2, '0')}';
    onDatePicked(picked);
  }

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
            'Create account',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fill in the details to get started.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: nameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Full name',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: emailController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email address',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter your email';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: countryCodeController,
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'Country code',
              prefixIcon: Icon(Icons.public_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: contactController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Contact number',
              prefixIcon: Icon(Icons.call_outlined),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Enter your contact number';
              }
              if (int.tryParse(v.trim()) == null) {
                return 'Enter a valid contact number';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: altContactController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Alternate contact number (optional)',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return null;
              if (int.tryParse(v.trim()) == null) {
                return 'Enter a valid contact number';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: dobController,
            readOnly: true,
            onTap: () => _pickDate(context),
            decoration: const InputDecoration(
              labelText: 'Date of birth (optional)',
              prefixIcon: Icon(Icons.cake_outlined),
              suffixIcon: Icon(Icons.calendar_today_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.next,
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
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter a password';
              if (v.length < 6) return 'At least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: confirmController,
            obscureText: obscureConfirm,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              labelText: 'Confirm password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: obscureConfirm ? 'Show password' : 'Hide password',
                icon: Icon(
                  obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: onToggleConfirm,
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Confirm your password';
              if (v != passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'Create account',
            icon: Icons.person_add_rounded,
            onPressed: onSubmit,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  'Already have an account?',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: onSwitchToSignIn,
                child: const Text('Sign in'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

