import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/account_nature.dart';
import '../models/create_account_nature_request.dart';
import '../screens/account_nature_screen.dart';
import '../viewModel/account_nature_view_model.dart';
import '../widgets/account_nature_add_dialog.dart';
import '../widgets/account_nature_card.dart';

/// State for [AccountNatureScreen]. Kept out of the screen file to follow the
/// StatefulWidget split pattern.
class AccountNatureScreenState extends State<AccountNatureScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AccountNatureViewModel>().loadAccountNatures();
    });
  }

  Future<void> _openAddDialog() async {
    final result = await showDialog<CreateAccountNatureRequest>(
      context: context,
      builder: (_) => const AccountNatureAddDialog(),
    );
    if (result == null || !mounted) return;
    await context.read<AccountNatureViewModel>().addAccountNature(result);
  }

  Future<void> _confirmDelete(
    AccountNatureViewModel viewModel,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete nature?'),
        content: const Text(
          'This will remove the account nature from your master.',
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
    if (confirmed == true) await viewModel.deleteAccountNature(id);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AccountNatureViewModel>();
    final natures = viewModel.filteredAccountNatures;

    return Scaffold(
      appBar: AppBar(title: const Text('Account Natures')),
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
                    label: const Text('Add nature'),
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
                    : natures.isEmpty
                    ? const _EmptyState()
                    : LayoutBuilder(
                        builder: (context, constraints) =>
                            constraints.maxWidth >= 720
                            ? _NatureTable(natures: natures)
                            : ListView.separated(
                                itemCount: natures.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final nature = natures[index];
                                  return AccountNatureCard(
                                    nature: nature,
                                    onDelete: () =>
                                        _confirmDelete(viewModel, nature.id),
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

/// Table view of account natures for wide screens.
///
/// Built from flex-aligned rows instead of [DataTable] so it fills the
/// available width, scrolls vertically when the list is long (with a header
/// that stays pinned), and can reuse the same icon/color treatment as
/// [AccountNatureCard]. Rows are read-only — deleting only happens from the
/// card view.
class _NatureTable extends StatelessWidget {
  const _NatureTable({required this.natures});

  final List<AccountNature> natures;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const _NatureTableHeader(),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: ListView.separated(
              itemCount: natures.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) => _NatureTableRow(
                slNo: index + 1,
                nature: natures[index],
                zebra: index.isOdd,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NatureTableHeader extends StatelessWidget {
  const _NatureTableHeader();

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        children: [
          Expanded(child: Text('SL NO', style: labelStyle)),
          Expanded(child: Text('NAME', style: labelStyle)),
          Expanded(
            child: Text('CODE', style: labelStyle, textAlign: TextAlign.center),
          ),
          Expanded(child: Text('DESCRIPTION', style: labelStyle)),
        ],
      ),
    );
  }
}

class _NatureTableRow extends StatelessWidget {
  const _NatureTableRow({
    required this.slNo,
    required this.nature,
    required this.zebra,
  });

  final int slNo;
  final AccountNature nature;
  final bool zebra;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: zebra ? AppColors.background.withValues(alpha: 0.4) : null,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$slNo',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              nature.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: nature.code == null
                  ? Text(
                      '—',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${nature.code}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
            ),
          ),
          Expanded(
            child: Text(
              nature.description ?? '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
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
            Icons.category_outlined,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No account natures found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search or add a new nature.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
