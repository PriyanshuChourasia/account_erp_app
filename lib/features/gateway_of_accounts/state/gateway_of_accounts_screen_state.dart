import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/app_theme.dart';
import '../../../modules/organisational_masters/modules/company/models/create_company_request.dart';
import '../../../modules/organisational_masters/modules/company/viewModel/company_view_model.dart';
import '../../../modules/accounting_masters/screens/accounting_masters_screen.dart';
import '../../../modules/inventory_masters/screens/inventory_masters_screen.dart';
import '../../../modules/organisational_masters/screens/organisational_masters_screen.dart';
import '../../../modules/payroll_masters/screens/payroll_masters_screen.dart';
import '../../../modules/utility/screens/utility_screen.dart';
import '../../../routing/app_routes.dart';
import '../../auth/viewModel/auth_view_model.dart';
import '../screens/gateway_of_accounts_screen.dart';

/// Landing screen shown after login/registration.
///
/// Shows the user's companies and lets them select or create a workspace.
/// State lives in `state/gateway_of_accounts_screen_state.dart`.
class GatewayOfAccountsScreenState extends State<GatewayOfAccountsScreen> {
  /// Below this width the panels stack into a single scrollable column.
  static const double _mediumBreakpoint = 700;

  /// At or above this width all three panels sit side by side.
  static const double _wideBreakpoint = 1100;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthViewModel>();
    final userName = auth.user?.name ?? 'User';

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isCompact = width < _mediumBreakpoint;
              final isWide = width >= _wideBreakpoint;
              final horizontalPadding = isCompact ? 16.0 : 24.0;
              final verticalPadding = isCompact ? 16.0 : 24.0;
              final gap = isCompact ? 16.0 : 20.0;

              // Panels only scroll internally in the side-by-side layouts,
              // where their height is bounded. In the compact stacked layout
              // the whole page scrolls instead, avoiding nested scroll views.
              final companyPanel = _CompanyListEmptyState(
                scrollable: !isCompact,
              );
              final actionsPanel = _ActionsCard(scrollable: !isCompact);
              final mastersPanel = _MastersLadderCard(scrollable: !isCompact);

              final Widget content;
              if (isWide) {
                content = Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 4, child: companyPanel),
                    SizedBox(width: gap),
                    Expanded(flex: 3, child: actionsPanel),
                    SizedBox(width: gap),
                    Expanded(flex: 3, child: mastersPanel),
                  ],
                );
              } else if (!isCompact) {
                content = Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 4, child: companyPanel),
                    SizedBox(width: gap),
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          Expanded(flex: 2, child: actionsPanel),
                          SizedBox(height: gap),
                          Expanded(flex: 3, child: mastersPanel),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                content = Column(
                  children: [
                    companyPanel,
                    SizedBox(height: gap),
                    actionsPanel,
                    SizedBox(height: gap),
                    mastersPanel,
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(theme, userName, horizontalPadding),
                  // Content spans the full width and height of the window;
                  // only the compact layout scrolls as a whole page.
                  Expanded(
                    child: isCompact
                        ? SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: verticalPadding,
                            ),
                            child: content,
                          )
                        : Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: verticalPadding,
                            ),
                            child: content,
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    ThemeData theme,
    String userName,
    double horizontalPadding,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
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
        ],
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

/// Opens the create-company screen directly, without navigating to the
/// companies list screen (which would otherwise fetch the company list).
Future<void> _createCompany(BuildContext context) async {
  // Untyped: routes built from the `routes:` table are `Route<dynamic>`, so
  // a typed `pushNamed<T>` fails its internal cast at runtime.
  final result =
      await Navigator.of(context).pushNamed(AppRoutes.createCompany)
          as CreateCompanyRequest?;
  if (result == null || !context.mounted) return;
  final viewModel = context.read<CompanyViewModel>();
  final success = await viewModel.addCompany(result);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        success
            ? 'Company "${result.name}" created.'
            : (viewModel.error ?? 'Something went wrong. Please try again.'),
      ),
    ),
  );
}

/// Left panel: Current Period / Current Date header, then the company list
/// (empty state until the backend is wired up).
class _CompanyListEmptyState extends StatelessWidget {
  const _CompanyListEmptyState({this.scrollable = true});

  /// When false the card sizes to its content and the page scrolls instead.
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: _PeriodDateItem(
                label: 'Current Period',
                value: '—',
                icon: Icons.calendar_today_outlined,
              ),
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
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
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
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _createCompany(context),
                icon: const Icon(Icons.add_business_rounded, size: 18),
                label: const Text('Create Company'),
              ),
            ],
          ),
        ),
      ],
    );

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: Padding(
        padding: const EdgeInsets.all(24),
        // In the side-by-side layouts the card scrolls internally instead of
        // overflowing when it is given little height (a short window).
        child: scrollable ? SingleChildScrollView(child: content) : content,
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
    this.icon,
  });

  final String label;
  final String value;
  final bool alignEnd;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final crossAxis = alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final valueText = Text(
      value,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );

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
        icon == null
            ? valueText
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  valueText,
                ],
              ),
      ],
    );
  }
}

/// Right panel: a centered card of quick actions.
class _ActionsCard extends StatelessWidget {
  const _ActionsCard({this.scrollable = true});

  /// When false the card sizes to its content and the page scrolls instead.
  final bool scrollable;

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
    final actions = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionLink(
              icon: Icons.add_business_rounded,
              label: 'Create Company',
              onTap: () => _createCompany(context),
            ),
            const Divider(height: 1),
            _ActionLink(
              icon: Icons.backup_outlined,
              label: 'Backup',
              onTap: () {
                // TODO: Trigger backup flow.
              },
            ),
            const Divider(height: 1),
            _ActionLink(
              icon: Icons.restore_outlined,
              label: 'Restore',
              onTap: () {
                // TODO: Trigger restore flow.
              },
            ),
            const Divider(height: 1),
            _ActionLink(
              icon: Icons.logout_rounded,
              label: 'Logout',
              isDestructive: true,
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: scrollable ? SingleChildScrollView(child: actions) : actions,
        ),
      ),
    );
  }
}

/// Right sub-panel: a grid of small cards, one per master domain, each
/// opening that domain's index screen.
class _MastersLadderCard extends StatelessWidget {
  const _MastersLadderCard({this.scrollable = true});

  /// When false the card sizes to its content and the page scrolls instead.
  final bool scrollable;

  static const _items = [
    (
      icon: Icons.account_balance_rounded,
      label: 'Accounting',
      color: Color(0xFF2E5BBA),
    ),
    (
      icon: Icons.inventory_2_rounded,
      label: 'Inventory',
      color: Color(0xFF0F8A6B),
    ),
    (icon: Icons.payments_rounded, label: 'Payroll', color: Color(0xFFB7791F)),
    (
      icon: Icons.build_circle_rounded,
      label: 'Utility',
      color: Color(0xFF6B46C1),
    ),
    (
      icon: Icons.corporate_fare_rounded,
      label: 'Organisation',
      color: Color(0xFFC53030),
    ),
    (icon: Icons.business_rounded, label: 'Company', color: Color(0xFF2B6CB0)),
  ];

  void _open(BuildContext context, int index) {
    // The domain index screens are built to sit inside the dashboard shell,
    // so give them their own Scaffold when pushed from here.
    final Widget body;
    switch (index) {
      case 0:
        body = const AccountingMastersScreen();
      case 1:
        body = const InventoryMastersScreen();
      case 2:
        body = const PayrollMastersScreen();
      case 3:
        body = const UtilityScreen();
      case 4:
        body = const OrganisationalMastersScreen();
      default:
        Navigator.of(context).pushNamed(AppRoutes.companies);
        return;
    }
    final title = _items[index].label;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: body,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 14),
          child: Text(
            'Module Masters',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        // Small fixed-size tiles: as many per row as fit, each at most
        // 120px wide.
        GridView.extent(
          maxCrossAxisExtent: 120,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            for (final (index, item) in _items.indexed)
              _MasterTile(
                icon: item.icon,
                label: item.label,
                color: item.color,
                onTap: () => _open(context, index),
              ),
          ],
        ),
      ],
    );

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        // In the side-by-side layouts the grid scrolls internally instead of
        // overflowing when the card is given little height.
        child: scrollable ? SingleChildScrollView(child: content) : content,
      ),
    );
  }
}

/// One small card of the [_MastersLadderCard] grid: icon on top, title below.
class _MasterTile extends StatelessWidget {
  const _MasterTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          // Scales down rather than overflowing with large system text.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 24, color: color),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A link-styled row (icon + underlined text, no box/border) used for each
/// quick action (Create Company, Backup, Restore, Logout) inside
/// [_ActionsCard], which itself carries the border and light-green
/// background for the whole group.
class _ActionLink extends StatelessWidget {
  const _ActionLink({
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                  decorationColor: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
