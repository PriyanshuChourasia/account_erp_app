import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/stock_group.dart';
import '../screens/stock_group_screen.dart';
import '../viewModel/stock_group_view_model.dart';
import '../widgets/stock_group_add_dialog.dart';
import '../widgets/stock_group_card.dart';

/// State for [StockGroupScreen]. Kept out of the screen file to follow the
/// StatefulWidget split pattern.
class StockGroupScreenState extends State<StockGroupScreen> {
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) context.read<StockGroupViewModel>().loadStockGroups();
    // });
  }

  Future<void> _openAddDialog() async {
    final result = await showDialog<
        ({
          String name,
          String? code,
          String? alias,
          int? parentId,
          String? description,
          bool shouldAddQuantities,
          bool setAlterGstDetail
        })>(
      context: context,
      builder: (_) => const StockGroupAddDialog(),
    );
    if (result == null || !mounted) return;
    await context.read<StockGroupViewModel>().addStockGroup(
          name: result.name,
          code: result.code,
          alias: result.alias,
          parentId: result.parentId,
          description: result.description,
          shouldAddQuantities: result.shouldAddQuantities,
          setAlterGstDetail: result.setAlterGstDetail,
        );
  }

  Future<void> _confirmDelete(
    StockGroupViewModel viewModel,
    int id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete group?'),
        content: const Text(
          'This will remove the stock group from your master.',
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
    if (confirmed == true) await viewModel.deleteStockGroup(id);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StockGroupViewModel>();
    final groups = viewModel.filteredStockGroups;

    return Scaffold(
      appBar: AppBar(title: const Text('Stock Groups')),
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
                        hintText: 'Search by name, code or ID...',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _openAddDialog,
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
                    color:
                        Theme.of(context).colorScheme.error.withValues(alpha: 0.08),
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
                                    ? _StockGroupTable(
                                        groups: groups,
                                        onDelete: (id) =>
                                            _confirmDelete(viewModel, id),
                                      )
                                    : ListView.separated(
                                        itemCount: groups.length,
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(height: 10),
                                        itemBuilder: (context, index) {
                                          final group = groups[index];
                                          return StockGroupCard(
                                            group: group,
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

/// Table view of stock groups for wide screens.
class _StockGroupTable extends StatelessWidget {
  const _StockGroupTable({required this.groups, required this.onDelete});

  final List<StockGroup> groups;
  final ValueChanged<int> onDelete;

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
            DataColumn(label: Text('Code')),
            DataColumn(label: Text('Alias')),
            DataColumn(label: Text('Description')),
            DataColumn(label: Text('Quantities')),
            DataColumn(label: Text('GST')),
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
                  DataCell(Text(group.code ?? '—')),
                  DataCell(Text(group.alias ?? '—')),
                  DataCell(
                    Text(
                      group.description ?? '—',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataCell(_CheckCell(enabled: group.shouldAddQuantities)),
                  DataCell(_CheckCell(enabled: group.setAlterGstDetail)),
                  DataCell(_StatusBadge(isActive: group.isActive)),
                  DataCell(
                    IconButton(
                      tooltip: 'Delete group',
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => onDelete(group.id),
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

class _CheckCell extends StatelessWidget {
  const _CheckCell({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return enabled
        ? const Icon(
            Icons.check_circle_rounded,
            size: 20,
            color: Color(0xFF059669),
          )
        : Text(
            '—',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
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
            Icons.folder_open_rounded,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No stock groups found',
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
