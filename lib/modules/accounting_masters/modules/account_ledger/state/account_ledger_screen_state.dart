import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../../account_group/models/account_group.dart';
import '../models/account_ledger.dart';
import '../screens/account_ledger_screen.dart';
import '../viewModel/account_ledger_view_model.dart';
import '../widgets/account_ledger_card.dart';

/// State for [AccountLedgerScreen]. Kept out of the screen file to follow the
/// StatefulWidget split pattern.
class AccountLedgerScreenState extends State<AccountLedgerScreen> {
  String _groupQuery = '';
  int? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final viewModel = context.read<AccountLedgerViewModel>();
      viewModel.loadAccountLedgers();
      viewModel.loadAccountGroups();
    });
  }

  Future<void> _confirmDelete(AccountLedgerViewModel viewModel, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete ledger?'),
        content: const Text(
          'This will remove the account ledger from your master.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) await viewModel.deleteAccountLedger(id);
  }

  bool _matchesGroup(AccountLedgerViewModel viewModel, AccountLedger ledger) {
    final query = _groupQuery.trim().toLowerCase();
    final matchesQuery =
        query.isEmpty ||
        viewModel.groupNameOf(ledger).toLowerCase().contains(query);
    final matchesGroup =
        _selectedGroupId == null || ledger.groupId == _selectedGroupId;
    return matchesQuery && matchesGroup;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AccountLedgerViewModel>();
    final ledgers = viewModel.filteredAccountLedgers;
    final activeLedgers = ledgers
        .where(
          (ledger) =>
              ledger.isActive && _matchesGroup(viewModel, ledger),
        )
        .toList();
    final inactiveLedgers = ledgers
        .where((ledger) => !ledger.isActive)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Account Ledgers')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _KeyValueField(
                label: 'Name',
                onChanged: viewModel.setNameQuery,
              ),
              const SizedBox(height: 12),
              _KeyValueField(
                label: 'Alias',
                onChanged: viewModel.setAliasQuery,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _LedgerGrid(
                              title: 'Active',
                              showTitle: false,
                              ledgers: activeLedgers,
                              groupName: viewModel.groupNameOf,
                              onDelete: (id) =>
                                  _confirmDelete(viewModel, id),
                              underFilter: _UnderFilter(
                                groups: viewModel.accountGroups,
                                selectedGroupId: _selectedGroupId,
                                onSearchChanged: (value) =>
                                    setState(() => _groupQuery = value),
                                onGroupChanged: (value) => setState(
                                  () => _selectedGroupId = value,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _LedgerGrid(
                              title: 'Inactive',
                              ledgers: inactiveLedgers,
                              groupName: viewModel.groupNameOf,
                              onDelete: (id) =>
                                  _confirmDelete(viewModel, id),
                            ),
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

/// One grid half of the account ledgers screen.
class _LedgerGrid extends StatelessWidget {
  const _LedgerGrid({
    required this.title,
    required this.ledgers,
    required this.groupName,
    required this.onDelete,
    this.underFilter,
    this.showTitle = true,
  });

  final String title;
  final List<AccountLedger> ledgers;
  final String Function(AccountLedger) groupName;
  final ValueChanged<int> onDelete;
  final Widget? underFilter;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle) ...[
            Row(
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${ledgers.length}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          if (underFilter != null) ...[
            underFilter!,
            const SizedBox(height: 10),
          ],
          Expanded(
            child: ledgers.isEmpty
                ? Center(
                    child: Text(
                      'No $title ledgers',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: ledgers.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final ledger = ledgers[index];
                      return AccountLedgerCard(
                        ledger: ledger,
                        groupName: groupName(ledger),
                        onDelete: () => onDelete(ledger.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Key-value styled 'Under' filter: search box plus a group select dropdown.
class _UnderFilter extends StatelessWidget {
  const _UnderFilter({
    required this.groups,
    required this.selectedGroupId,
    required this.onSearchChanged,
    required this.onGroupChanged,
  });

  final List<AccountGroup> groups;
  final int? selectedGroupId;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<int?> onGroupChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            'Under',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: TextField(
            onChanged: onSearchChanged,
            decoration: const InputDecoration(
              isDense: true,
              hintText: 'Search group...',
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        DropdownButtonHideUnderline(
          child: DropdownButton<int?>(
            value: selectedGroupId,
            hint: const Text('All groups'),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('All groups'),
              ),
              for (final group in groups)
                DropdownMenuItem<int?>(
                  value: group.id,
                  child: Text(group.name),
                ),
            ],
            onChanged: onGroupChanged,
          ),
        ),
      ],
    );
  }
}

/// Key-value styled input row: label on the left, input field on the right.
class _KeyValueField extends StatelessWidget {
  const _KeyValueField({required this.label, required this.onChanged});

  final String label;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: TextField(
            onChanged: onChanged,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}