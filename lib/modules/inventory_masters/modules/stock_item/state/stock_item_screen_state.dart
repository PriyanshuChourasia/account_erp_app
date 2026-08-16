import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../../stock_category/viewModel/stock_category_view_model.dart';
import '../../stock_group/viewModel/stock_group_view_model.dart';
import '../../unit/viewModel/unit_view_model.dart';
import '../models/stock_item.dart';
import '../screens/stock_item_screen.dart';
import '../viewModel/stock_item_view_model.dart';
import '../widgets/stock_item_add_dialog.dart';
import '../widgets/stock_item_card.dart';

/// State for [StockItemScreen]. Kept out of the screen file to follow the
/// StatefulWidget split pattern.
class StockItemScreenState extends State<StockItemScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<StockItemViewModel>().loadStockItems();
      final groupViewModel = context.read<StockGroupViewModel>();
      if (groupViewModel.stockGroups.isEmpty && !groupViewModel.isLoading) {
        groupViewModel.loadStockGroups();
      }
      final categoryViewModel = context.read<StockCategoryViewModel>();
      if (categoryViewModel.stockCategories.isEmpty &&
          !categoryViewModel.isLoading) {
        categoryViewModel.loadStockCategories();
      }
      final unitViewModel = context.read<UnitViewModel>();
      if (unitViewModel.units.isEmpty && !unitViewModel.isLoading) {
        unitViewModel.loadUnits();
      }
    });
  }

  Future<void> _openAddDialog() async {
    final result =
        await showDialog<
          ({
            String name,
            String? alias,
            String? code,
            String? description,
            int? stockGroupId,
            int? stockCategoryId,
            int? unitId,
          })
        >(context: context, builder: (_) => const StockItemAddDialog());
    if (result == null || !mounted) return;
    await context.read<StockItemViewModel>().addStockItem(
      name: result.name,
      alias: result.alias,
      code: result.code,
      description: result.description,
      stockGroupId: result.stockGroupId,
      stockCategoryId: result.stockCategoryId,
      unitId: result.unitId,
    );
  }

  Future<void> _confirmDelete(StockItemViewModel viewModel, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete item?'),
        content: const Text(
          'This will remove the stock item from your master.',
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
    if (confirmed == true) await viewModel.deleteStockItem(id);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StockItemViewModel>();
    final groups = context.watch<StockGroupViewModel>().stockGroups;
    final categories = context.watch<StockCategoryViewModel>().stockCategories;
    final units = context.watch<UnitViewModel>().units;
    final items = viewModel.filteredStockItems;

    String groupName(int? id) =>
        groups.where((group) => group.id == id).firstOrNull?.name ?? '—';
    String categoryName(int? id) =>
        categories.where((category) => category.id == id).firstOrNull?.name ??
        '—';
    String unitName(int? id) =>
        units.where((unit) => unit.id == id).firstOrNull?.name ?? '—';

    return Scaffold(
      appBar: AppBar(title: const Text('Stock Items')),
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
                    label: const Text('Add item'),
                  ),
                ],
              ),
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
                    : items.isEmpty
                    ? const _EmptyState()
                    : LayoutBuilder(
                        builder: (context, constraints) =>
                            constraints.maxWidth >= 720
                            ? _StockItemTable(
                                items: items,
                                groupName: groupName,
                                categoryName: categoryName,
                                unitName: unitName,
                                onDelete: (id) => _confirmDelete(viewModel, id),
                              )
                            : ListView.separated(
                                itemCount: items.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  return StockItemCard(
                                    item: item,
                                    onDelete: () =>
                                        _confirmDelete(viewModel, item.id),
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

/// Table view of stock items for wide screens.
class _StockItemTable extends StatelessWidget {
  const _StockItemTable({
    required this.items,
    required this.groupName,
    required this.categoryName,
    required this.unitName,
    required this.onDelete,
  });

  final List<StockItem> items;
  final String Function(int?) groupName;
  final String Function(int?) categoryName;
  final String Function(int?) unitName;
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
            DataColumn(label: Text('Group')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Unit')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('')),
          ],
          rows: [
            for (final item in items)
              DataRow(
                cells: [
                  DataCell(Text('${item.id}')),
                  DataCell(
                    Text(
                      item.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataCell(Text(item.code ?? '—')),
                  DataCell(Text(groupName(item.stockGroupId))),
                  DataCell(Text(categoryName(item.stockCategoryId))),
                  DataCell(Text(unitName(item.unitId))),
                  DataCell(_StatusBadge(isActive: item.isActive)),
                  DataCell(
                    IconButton(
                      tooltip: 'Delete item',
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => onDelete(item.id),
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
            Icons.inventory_2_rounded,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No stock items found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search or add a new item.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
