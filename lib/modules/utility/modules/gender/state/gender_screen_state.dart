import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/create_gender_request.dart';
import '../models/gender.dart';
import '../screens/gender_screen.dart';
import '../viewModel/gender_view_model.dart';
import '../widgets/gender_add_dialog.dart';
import '../widgets/gender_card.dart';

/// State for [GenderScreen]. Kept out of the screen file to follow the
/// StatefulWidget split pattern.
class GenderScreenState extends State<GenderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GenderViewModel>().loadGenders();
    });
  }

  Future<void> _openDialog({Gender? editing}) async {
    final result = await showDialog<CreateGenderRequest>(
      context: context,
      builder: (_) => GenderAddDialog(initialGender: editing),
    );
    if (result == null || !mounted) return;
    final viewModel = context.read<GenderViewModel>();
    if (editing == null) {
      await viewModel.addGender(result);
    } else {
      await viewModel.updateGender(editing.id, result);
    }
  }

  Future<void> _confirmDelete(GenderViewModel viewModel, Gender gender) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete gender?'),
        content: Text('This will remove "${gender.name}" from your master.'),
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
    if (confirmed == true) await viewModel.deleteGender(gender.id);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GenderViewModel>();
    final genders = viewModel.filteredGenders;
    final isNarrow = MediaQuery.sizeOf(context).width < 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Genders')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isNarrow ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: viewModel.setQuery,
                      decoration: const InputDecoration(
                        hintText: 'Search by name, code or description...',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Icon-only on phones so the search field keeps its room.
                  if (isNarrow)
                    IconButton.filled(
                      tooltip: 'Add gender',
                      onPressed: _openDialog,
                      icon: const Icon(Icons.add_rounded),
                    )
                  else
                    FilledButton.icon(
                      onPressed: _openDialog,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add gender'),
                    ),
                ],
              ),
              if (viewModel.error != null) ...[
                const SizedBox(height: 16),
                _ErrorBanner(message: viewModel.error!),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : genders.isEmpty
                    ? const _EmptyState()
                    : LayoutBuilder(
                        builder: (context, constraints) =>
                            constraints.maxWidth >= 720
                            ? _GenderTable(
                                genders: genders,
                                minWidth: constraints.maxWidth,
                                onEdit: (gender) =>
                                    _openDialog(editing: gender),
                                onDelete: (gender) =>
                                    _confirmDelete(viewModel, gender),
                              )
                            : ListView.separated(
                                itemCount: genders.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final gender = genders[index];
                                  return GenderCard(
                                    gender: gender,
                                    onEdit: () => _openDialog(editing: gender),
                                    onDelete: () =>
                                        _confirmDelete(viewModel, gender),
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

/// Full-width table of genders for wide screens.
class _GenderTable extends StatelessWidget {
  const _GenderTable({
    required this.genders,
    required this.minWidth,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Gender> genders;
  final double minWidth;
  final ValueChanged<Gender> onEdit;
  final ValueChanged<Gender> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const headerStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
    );
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: minWidth),
            child: DataTable(
              columnSpacing: 24,
              headingRowColor: const WidgetStatePropertyAll(AppColors.primary),
              headingTextStyle: headerStyle,
              columns: const [
                DataColumn(label: Text('SL No.')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Code')),
                DataColumn(label: Text('Description')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: [
                for (final (index, gender) in genders.indexed)
                  DataRow(
                    cells: [
                      DataCell(Text('${index + 1}')),
                      DataCell(
                        Text(
                          gender.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DataCell(Text(gender.code ?? '—')),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: Text(
                            gender.description ?? '—',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(GenderStatusBadge(isActive: gender.isActive)),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Edit gender',
                              icon: const Icon(
                                Icons.edit_outlined,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () => onEdit(gender),
                            ),
                            IconButton(
                              tooltip: 'Delete gender',
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () => onDelete(gender),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: errorColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: errorColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: errorColor),
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
            Icons.wc_rounded,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No genders found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search or add a new gender.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
