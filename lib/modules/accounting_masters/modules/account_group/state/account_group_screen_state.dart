import 'package:account_erp_app/modules/accounting_masters/modules/account_group/models/create_account_group_request.dart';
import 'package:account_erp_app/modules/accounting_masters/modules/account_group/models/update_account_group_request.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/account_group.dart';
import '../screens/account_group_screen.dart';
import '../viewModel/account_group_view_model.dart';
import '../widgets/account_group_card.dart';
import '../widgets/account_group_create_form.dart';

/// State for [AccountGroupScreen]. Kept out of the screen file to follow the
/// StatefulWidget split pattern.
class AccountGroupScreenState extends State<AccountGroupScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AccountGroupViewModel>().loadAccountGroups();
    });
  }

  Future<void> _openForm([AccountGroup? group]) async {
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (_) => AccountGroupCreateForm(initialGroup: group),
      ),
    );
    if (result == null || !mounted) return;
    final viewModel = context.read<AccountGroupViewModel>();
    if (result is UpdateAccountGroupRequest) {
      await viewModel.updateAccountGroup(result);
    } else if (result is CreateAccountGroupRequest) {
      await viewModel.addAccountGroup(result);
    }
  }

  Future<void> _confirmDelete(
    AccountGroupViewModel viewModel,
    int id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete group?'),
        content: const Text(
          'This will remove the accounting group from your master.',
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
    if (confirmed == true) await viewModel.deleteAccountGroup(id);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AccountGroupViewModel>();
    final groups = viewModel.filteredAccountGroups;

    return Scaffold(
      appBar: AppBar(title: const Text('Account Groups')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: viewModel.setQuery,
                      decoration: const InputDecoration(
                        hintText: 'Search by name, alias or ID...',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _openForm,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add group'),
                  ),
                ],
              ),
              if (viewModel.error != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 18,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          viewModel.error!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : groups.isEmpty
                        ? const _EmptyState()
                        : LayoutBuilder(
                            builder: (context, constraints) =>
                                constraints.maxWidth >= 720
                                    ? _AccountGroupTable(
                                        groups: groups,
                                        onEdit: (id) => _openForm(
                                          groups
                                              .firstWhere(
                                                  (g) => g.id == id),
                                        ),
                                        onDelete: (id) =>
                                            _confirmDelete(viewModel, id),
                                      )
                                    : ListView.separated(
                                        itemCount: groups.length,
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(height: 10),
                                        itemBuilder: (context, index) {
                                          final group = groups[index];
                                          return AccountGroupCard(
                                            group: group,
                                            onEdit: () =>
                                                _openForm(group),
                                            onDelete: () => _confirmDelete(
                                                viewModel, group.id),
                                          );
                                        },
                                      ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Table view of accounting groups for wide screens.
class _AccountGroupTable extends StatelessWidget {
  const _AccountGroupTable({
    required this.groups,
    required this.onEdit,
    required this.onDelete,
  });

  final List<AccountGroup> groups;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onDelete;

  String _underName(AccountGroup group) {
    final parent = groups
        .where((candidate) => candidate.id == group.parentId)
        .firstOrNull;
    return parent?.name ?? '—';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 24,
          headingRowColor: WidgetStatePropertyAll(AppColors.background),
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Alias')),
            DataColumn(label: Text('Under')),
            DataColumn(label: Text('Description')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('')),
          ],
          rows: [
            for (final group in groups)
              DataRow(
                cells: [
                  DataCell(Text('${group.id}')),
                  DataCell(
                    Text(
                      group.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataCell(Text(group.alias ?? '—')),
                  DataCell(Text(_underName(group))),
                  DataCell(
                    Text(
                      group.description ?? '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(_StatusBadge(isActive: group.isActive)),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Edit group',
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => onEdit(group.id),
                        ),
                        IconButton(
                          tooltip: 'Delete group',
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => onDelete(group.id),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.gradientGreen.first.withValues(alpha: 0.12)
            : AppColors.textSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: isActive
              ? AppColors.gradientGreen.first
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_tree_outlined,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No accounting groups found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search or add a new group.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
