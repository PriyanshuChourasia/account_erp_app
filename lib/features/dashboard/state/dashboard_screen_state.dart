import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/app_theme.dart';
import '../../../modules/accounting_masters/screens/accounting_masters_screen.dart';
import '../../../modules/inventory_masters/screens/inventory_masters_screen.dart';
import '../../../modules/items/screens/item_screen.dart';
import '../../../modules/organisational_masters/screens/organisational_masters_screen.dart';
import '../screens/dashboard_screen.dart';
import '../viewModel/dashboard_view_model.dart';
import '../widgets/sidebar.dart';
import '../widgets/sidebar_menu.dart';
import '../widgets/stat_card.dart';

/// State for [DashboardScreen].
class DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<DashboardViewModel>().loadStats();
    });
  }

  String get _selectedLabel {
    final items = sidebarMenuItems();
    return (_selectedIndex >= 0 && _selectedIndex < items.length)
        ? items[_selectedIndex]['name'] as String
        : 'Account ERP';
  }

  void _selectSection(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'You will need to sign in again to access your workspace.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      widget.onLogout?.call();
      // AuthGate swaps back to the login screen automatically.
    }
  }

  Widget _buildSection() {
    switch (_selectedIndex) {
      case 1:
        return const ItemScreen();
      case 2:
        return const AccountingMastersScreen();
      case 3:
        return const InventoryMastersScreen();
      case 4:
        return const OrganisationalMastersScreen();
      default:
        if (_selectedIndex == 0) return _buildDashboard();
        return _PlaceholderView(label: _selectedLabel);
    }
  }

  Widget _buildDashboard() {
    final dashboard = context.watch<DashboardViewModel>();
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Hello, ${widget.userName ?? 'there'}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            "Here's what's happening in your books today.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          if (dashboard.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            GridView.count(
              crossAxisCount: constraints.maxWidth >= 700 ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.35,
              children: [
                for (final stat in dashboard.stats) StatCard(stat: stat),
              ],
            ),
          const SizedBox(height: 24),
          const _RecentActivityCard(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Sidebar(
              selectedIndex: _selectedIndex,
              onNavigate: _selectSection,
              userName: widget.userName,
              onLogout: _confirmLogout,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionHeader(title: _selectedLabel),
                  Expanded(
                    child: Navigator(
                      key: ValueKey(_selectedIndex),
                      onGenerateRoute: (settings) => MaterialPageRoute<void>(
                        builder: (_) => _buildSection(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Top bar shown above every section's content.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder for sidebar sections that are not built yet.
class _PlaceholderView extends StatelessWidget {
  const _PlaceholderView({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 48,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              '$label is coming soon',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder "recent activity" panel — replace with real data later.
class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard();

  static const _items = [
    (
      icon: Icons.add_card_rounded,
      title: 'Invoice #INV-1042 raised',
      time: '2h ago',
    ),
    (
      icon: Icons.receipt_rounded,
      title: 'Payment received — Acme Corp',
      time: '5h ago',
    ),
    (
      icon: Icons.description_rounded,
      title: 'Monthly report generated',
      time: '1d ago',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent activity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            for (final item in _items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Icon(item.icon, size: 18, color: AppColors.primary),
                ),
                title: Text(
                  item.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  item.time,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
