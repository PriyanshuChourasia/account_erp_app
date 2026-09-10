import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/app_theme.dart';
import '../../../modules/organisational_masters/modules/company/models/create_company_request.dart';
import '../../../modules/organisational_masters/modules/company/viewModel/company_view_model.dart';
import '../../../modules/inventory_masters/modules/stock_item/screens/stock_item_screen.dart';
import '../../../modules/utility/modules/database_opr/screens/database_opr_screen.dart';
import '../../../modules/accounting_masters/modules/account_group/screens/account_group_screen.dart';
import '../../../modules/accounting_masters/modules/account_ledger/screens/account_ledger_screen.dart';
import '../../../modules/accounting_masters/modules/account_nature/screens/account_nature_screen.dart';
import '../../../modules/organisational_masters/modules/country/screens/country_screen.dart';
import '../../../modules/organisational_masters/modules/financial_year/screens/financial_year_screen.dart';
import '../../../modules/organisational_masters/modules/state/screens/state_screen.dart';
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
    final right = isWide
        ? const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _ActionsCard()),
              SizedBox(width: 16),
              Expanded(flex: 2, child: _MastersLadderCard()),
            ],
          )
        : const Column(
            children: [
              _ActionsCard(),
              SizedBox(height: 16),
              _MastersLadderCard(),
            ],
          );

    final panels = isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: left),
              const SizedBox(width: 20),
              Expanded(flex: 3, child: right),
            ],
          )
        : Column(children: [left, const SizedBox(height: 20), right]);

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
        // Wrapped in its own scroll view so the content scrolls internally
        // instead of overflowing when the card is given little height (a
        // short window in the wide, side-by-side layout).
        child: SingleChildScrollView(
          child: Column(
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
          ),
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
          ),
        ),
      ),
    );
  }
}

/// Right sub-panel: a plain list of organisational masters (Financial Year,
/// Country, State, Currency Info).
class _MastersLadderCard extends StatelessWidget {
  const _MastersLadderCard();

  static const _items = [
    (icon: Icons.calendar_month_rounded, label: 'Financial Year'),
    (icon: Icons.public_rounded, label: 'Country'),
    (icon: Icons.map_rounded, label: 'State'),
    (icon: Icons.currency_exchange_rounded, label: 'Currency Info'),
    (icon: Icons.inventory_2_rounded, label: 'Stock Item'),
    (icon: Icons.account_tree_rounded, label: 'Account Group'),
    (icon: Icons.category_rounded, label: 'Account Nature'),
    (icon: Icons.menu_book_rounded, label: 'Account Ledger'),
    (icon: Icons.storage_rounded, label: 'Database Operations'),
  ];

  void _open(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const FinancialYearScreen()),
        );
      case 1:
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const CountryScreen()));
      case 2:
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const StateScreen()));
      case 4:
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const StockItemScreen()));
      case 5:
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const AccountGroupScreen()));
      case 6:
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const AccountNatureScreen()));
      case 7:
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const AccountLedgerScreen()));
      case 8:
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const DatabaseOprScreen()));
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Currency master is coming soon.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        // Wrapped in its own scroll view so a tall item list scrolls
        // internally instead of overflowing when the card is given little
        // height (a short window in the wide, side-by-side layout).
        child: SingleChildScrollView(
          child: Column(
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
              ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return _MasterListItem(
                    icon: item.icon,
                    label: item.label,
                    onTap: () => _open(context, index),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One row of the [_MastersLadderCard] list.
class _MasterListItem extends StatelessWidget {
  const _MasterListItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
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
