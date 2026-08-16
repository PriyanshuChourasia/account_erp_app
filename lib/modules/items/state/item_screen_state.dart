import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/app_theme.dart';
import '../screens/item_screen.dart';
import '../viewModel/item_view_model.dart';
import '../widgets/item_add_dialog.dart';
import '../widgets/item_card.dart';

/// State for [ItemScreen]. Kept out of the screen file to follow the
/// StatefulWidget split pattern.
class ItemScreenState extends State<ItemScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ItemViewModel>().loadItems();
    });
  }

  Future<void> _openAddItemDialog() async {
    final result =
        await showDialog<
          ({String name, String category, double price, int stock})
        >(context: context, builder: (_) => const ItemAddDialog());
    if (result == null || !mounted) return;
    await context.read<ItemViewModel>().addItem(
      name: result.name,
      category: result.category,
      price: result.price,
      stock: result.stock,
    );
  }

  Future<void> _confirmDelete(ItemViewModel viewModel, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete item?'),
        content: const Text('This will remove the item from your catalogue.'),
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
    if (confirmed == true) await viewModel.deleteItem(id);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ItemViewModel>();
    final items = viewModel.filteredItems;

    return Padding(
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
                    hintText: 'Search by name, category or ID...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _openAddItemDialog,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add item'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                ? const _EmptyState()
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ItemCard(
                        item: item,
                        onDelete: () => _confirmDelete(viewModel, item.id),
                      );
                    },
                  ),
          ),
        ],
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
            Icons.inventory_2_outlined,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No items found',
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
