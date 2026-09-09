import 'package:account_erp_app/modules/accounting_masters/modules/account_group/models/create_account_group_request.dart';
import 'package:account_erp_app/modules/accounting_masters/modules/account_group/models/update_account_group_request.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../../account_nature/models/account_nature.dart';
import '../../account_nature/viewModel/account_nature_view_model.dart';
import '../models/account_group.dart';
import '../screens/account_group_screen.dart';
import '../viewModel/account_group_view_model.dart';
import '../widgets/account_group_card.dart';
import '../widgets/account_group_create_form.dart';

/// State for [AccountGroupScreen]. Kept out of the screen file to follow the
/// StatefulWidget split pattern.
class AccountGroupScreenState extends State<AccountGroupScreen> {
  bool _subledger = false;
  bool _nettReporting = false;
  String? _allocationMethod;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AccountGroupViewModel>().loadAccountGroups();
      final natureViewModel = context.read<AccountNatureViewModel>();
      if (natureViewModel.accountNatures.isEmpty && !natureViewModel.isLoading) {
        natureViewModel.loadAccountNatures();
      }
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

  Future<void> _confirmDelete(AccountGroupViewModel viewModel, int id) async {
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
    final natures = context.watch<AccountNatureViewModel>().accountNatures;
    final groups = viewModel.filteredAccountGroups;

    return Scaffold(
      appBar: AppBar(title: const Text('Account Groups')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Group Creation',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 20,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: 300,
                            child: Row(
                              children: [
                                Text(
                                  'Name:',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'Enter name',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Row(
                              children: [
                                Text(
                                  'Alias:',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'Enter alias',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 300,
                            child: Row(
                              children: [
                                Text(
                                  'Under:',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Builder(builder: (context) {
                                    final source =
                                        viewModel.accountingGroups.isEmpty
                                        ? AccountGroup.demo
                                        : viewModel.accountingGroups;
                                    final options = <(String, int?)>[
                                      ('Primary', null),
                                      for (final group in source)
                                        (group.name, group.id),
                                    ];
                                    return Autocomplete<(String, int?)>(
                                      displayStringForOption: (option) =>
                                          option.$1,
                                      optionsBuilder: (TextEditingValue value) {
                                        final query = value.text
                                            .trim()
                                            .toLowerCase();
                                        if (query.isEmpty) return options;
                                        return options
                                            .where(
                                              (option) => option.$1
                                                  .toLowerCase()
                                                  .contains(query),
                                            )
                                            .toList();
                                      },
                                      onSelected: (option) {},
                                      fieldViewBuilder: (
                                        context,
                                        controller,
                                        focusNode,
                                        _,
                                      ) {
                                        return TextField(
                                          controller: controller,
                                          focusNode: focusNode,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            hintText: 'Search and select',
                                            suffixIcon: const Icon(
                                              Icons.arrow_drop_down_rounded,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 8,
                                                ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        );
                                      },
                                      optionsViewBuilder: (
                                        context,
                                        onSelected,
                                        options,
                                      ) {
                                        return Align(
                                          alignment: Alignment.topLeft,
                                          child: Material(
                                            elevation: 4,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                maxWidth: 480,
                                              ),
                                              child: ListView(
                                                shrinkWrap: true,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                    ),
                                                children: [
                                                  for (final option in options)
                                                    ListTile(
                                                      dense: true,
                                                      leading: Icon(
                                                        option.$2 == null
                                                            ? Icons.home_rounded
                                                            : Icons.account_tree_rounded,
                                                        size: 20,
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                      title: Text(option.$1),
                                                      onTap: () =>
                                                          onSelected(option),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nature of Group:',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Builder(builder: (context) {
                              final natureSource = natures.isEmpty
                                  ? AccountNature.demo
                                  : natures;
                              final natureOptions = <(String, int)>[
                                for (final nature in natureSource)
                                  (nature.name, nature.id),
                              ];
                              return Autocomplete<(String, int)>(
                                displayStringForOption: (option) => option.$1,
                                optionsBuilder: (TextEditingValue value) {
                                  final query = value.text.trim().toLowerCase();
                                  if (query.isEmpty) return natureOptions;
                                  return natureOptions
                                      .where(
                                        (option) => option.$1
                                            .toLowerCase()
                                            .contains(query),
                                      )
                                      .toList();
                                },
                                onSelected: (option) {},
                                fieldViewBuilder: (
                                  context,
                                  controller,
                                  focusNode,
                                  _,
                                ) {
                                  return TextField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      hintText: 'Search and select',
                                      suffixIcon: const Icon(
                                        Icons.arrow_drop_down_rounded,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  );
                                },
                                optionsViewBuilder: (
                                  context,
                                  onSelected,
                                  options,
                                ) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      elevation: 4,
                                      borderRadius: BorderRadius.circular(12),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 480,
                                        ),
                                        child: ListView(
                                          shrinkWrap: true,
                                          padding:
                                              const EdgeInsets.symmetric(
                                                vertical: 4,
                                              ),
                                          children: [
                                            for (final option in options)
                                              ListTile(
                                                dense: true,
                                                leading: Icon(
                                                  Icons.category_rounded,
                                                  size: 20,
                                                  color: AppColors
                                                      .textSecondary,
                                                ),
                                                title: Text(option.$1),
                                                onTap: () =>
                                                    onSelected(option),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                               );
                              },
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Group Behaves like a sub-ledger:',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _YesNoChoice(
                                  label: 'Yes',
                                  selected: _subledger,
                                  onTap: () =>
                                      setState(() => _subledger = true),
                                ),
                                const SizedBox(width: 12),
                                _YesNoChoice(
                                  label: 'No',
                                  selected: !_subledger,
                                  onTap: () =>
                                      setState(() => _subledger = false),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nett Debit/Credit Balances for Reporting:',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _YesNoChoice(
                                  label: 'Yes',
                                  selected: _nettReporting,
                                  onTap: () =>
                                      setState(() => _nettReporting = true),
                                ),
                                const SizedBox(width: 12),
                                _YesNoChoice(
                                  label: 'No',
                                  selected: !_nettReporting,
                                  onTap: () =>
                                      setState(() => _nettReporting = false),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Method to allocate when used in purchase invoice:',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              width: 240,
                              child: DropdownButtonFormField<String?>(
                                initialValue: _allocationMethod,
                                isDense: true,
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'Select method',
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text('Not Applicable'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'FIFO',
                                    child: Text('First In First Out (FIFO)'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'LIFO',
                                    child: Text('Last In First Out (LIFO)'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Weighted Average',
                                    child: Text('Weighted Average'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Specific Identification',
                                    child: Text('Specific Identification'),
                                  ),
                                ],
                                onChanged: (value) =>
                                    setState(() => _allocationMethod = value),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (viewModel.error != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withValues(alpha: 0.08),
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
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
              Expanded(
                flex: 3,
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
                                  groups.firstWhere((g) => g.id == id),
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
                                    onEdit: () => _openForm(group),
                                    onDelete: () =>
                                        _confirmDelete(viewModel, group.id),
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

/// A selectable Yes/No choice button used for boolean fields.
class _YesNoChoice extends StatelessWidget {
  const _YesNoChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 18,
              color: selected
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
