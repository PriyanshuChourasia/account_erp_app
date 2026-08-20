import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/app_theme.dart';
import '../../../routing/app_routes.dart';
import '../../auth/viewModel/auth_view_model.dart';
import '../screens/gateway_of_accounts_screen.dart';

/// Landing screen shown after login/registration.
///
/// Shows the user's companies and lets them select or create a workspace.
/// State lives in `state/gateway_of_accounts_screen_state.dart`.
class GatewayOfAccountsScreenState extends State<GatewayOfAccountsScreen> {
  static const double _wideBreakpoint = 760;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;
    final auth = context.watch<AuthViewModel>();
    final userName = auth.user?.name ?? 'User';

    const left = _CompanyListEmptyState();
    const right = _ActionsCard();

    final panels = isWide
        ? IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 2, child: left),
                const SizedBox(width: 20),
                Expanded(flex: 3, child: right),
              ],
            ),
          )
        : const Column(children: [left, SizedBox(height: 20), right]);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8EEFB), Color(0xFFF4F6FB)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        userName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.account_circle_outlined,
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                      size: 22,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isWide
                    ? Padding(padding: const EdgeInsets.all(24), child: panels)
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: panels,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _formatDate(DateTime date) =>
    '${date.day}-${_monthNames[date.month - 1]}-${date.year}';

/// Left panel: Current Period / Current Date header, then the company list
/// (empty state until the backend is wired up).
class _CompanyListEmptyState extends StatelessWidget {
  const _CompanyListEmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: _PeriodDateItem(label: 'Current Period', value: '—'),
                ),
                Expanded(
                  child: _PeriodDateItem(
                    label: 'Current Date',
                    value: _formatDate(now),
                    alignEnd: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Text(
                'List of Companies',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.apartment_outlined,
                        color: AppColors.primary,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No companies yet',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Create a company or join one using an invite code.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A "label above value" item used for the Current Period / Current Date
/// header row, Tally-style.
class _PeriodDateItem extends StatelessWidget {
  const _PeriodDateItem({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final crossAxis = alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: crossAxis,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Right panel: a centered card of quick actions.
class _ActionsCard extends StatelessWidget {
  const _ActionsCard();

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthViewModel>().logout();
    if (context.mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionButton(
                  icon: Icons.add_business_rounded,
                  label: 'Create Company',
                  onTap: () {
                    // TODO: Navigate to create-company flow.
                  },
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  icon: Icons.backup_outlined,
                  label: 'Backup',
                  onTap: () {
                    // TODO: Trigger backup flow.
                  },
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  icon: Icons.restore_outlined,
                  label: 'Restore',
                  onTap: () {
                    // TODO: Trigger restore flow.
                  },
                ),
                const SizedBox(height: 12),
                _ActionButton(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  isDestructive: true,
                  onTap: () => _logout(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red.shade600 : AppColors.primary;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.4)),
        ),
        icon: Icon(icon, size: 20),
        label: Align(alignment: Alignment.centerLeft, child: Text(label)),
      ),
    );
  }
}
