import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/application_module.dart';
import '../models/create_application_module_request.dart';
import '../screens/application_module_screen.dart';
import '../viewModel/application_module_view_model.dart';
import '../widgets/application_module_add_dialog.dart';
import '../widgets/application_module_card.dart';

/// State for [ApplicationModuleScreen]. Kept out of the screen file to follow
/// the StatefulWidget split pattern.
class ApplicationModuleScreenState extends State<ApplicationModuleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ApplicationModuleViewModel>().loadApplicationModules();
      }
    });
  }

  Future<void> _openAddDialog() async {
    final result = await showDialog<CreateApplicationModuleRequest>(
      context: context,
      builder: (_) => const ApplicationModuleAddDialog(),
    );
    if (result == null || !mounted) return;
    await context.read<ApplicationModuleViewModel>().addApplicationModule(
      result,
    );
  }

  Future<void> _confirmDelete(
    ApplicationModuleViewModel viewModel,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete module?'),
        content: const Text(
          'This will remove the application module from your master.',
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
    if (confirmed == true) await viewModel.deleteApplicationModule(id);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ApplicationModuleViewModel>();
    final modules = viewModel.filteredApplicationModules;

    return Scaffold(
      appBar: AppBar(title: const Text('Application Modules')),
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
                        hintText: 'Search by name, code, endpoint...',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _openAddDialog,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add module'),
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
                    : modules.isEmpty
                    ? const _EmptyState()
                    : LayoutBuilder(
                        builder: (context, constraints) =>
                            constraints.maxWidth >= 720
                            ? _ModuleTable(
                                modules: modules,
                                onDelete: (id) =>
                                    _confirmDelete(viewModel, id),
                              )
                            : ListView.separated(
                                itemCount: modules.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final module = modules[index];
                                  return ApplicationModuleCard(
                                    module: module,
                                    onDelete: () =>
                                        _confirmDelete(viewModel, module.id),
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

/// Table view of application modules for wide screens.
///
/// Built from flex-aligned rows instead of [DataTable] so it fills the
/// available width, scrolls vertically when the list is long (with a header
/// that stays pinned), and can reuse the same icon/color treatment as
/// [ApplicationModuleCard].
class _ModuleTable extends StatelessWidget {
  const _ModuleTable({required this.modules, required this.onDelete});

  static const _slNoColumnWidth = 56.0;
  static const _statusColumnWidth = 90.0;
  static const _actionsColumnWidth = 56.0;

  final List<ApplicationModule> modules;
  final ValueChanged<String> onDelete;

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
          const _ModuleTableHeader(
            slNoColumnWidth: _slNoColumnWidth,
            statusColumnWidth: _statusColumnWidth,
            actionsColumnWidth: _actionsColumnWidth,
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: ListView.separated(
              itemCount: modules.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) => _ModuleTableRow(
                slNo: index + 1,
                module: modules[index],
                zebra: index.isOdd,
                slNoColumnWidth: _slNoColumnWidth,
                statusColumnWidth: _statusColumnWidth,
                actionsColumnWidth: _actionsColumnWidth,
                onDelete: () => onDelete(modules[index].id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleTableHeader extends StatelessWidget {
  const _ModuleTableHeader({
    required this.slNoColumnWidth,
    required this.statusColumnWidth,
    required this.actionsColumnWidth,
  });

  final double slNoColumnWidth;
  final double statusColumnWidth;
  final double actionsColumnWidth;

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
          SizedBox(
            width: slNoColumnWidth,
            child: Text('SL NO', style: labelStyle),
          ),
          Expanded(flex: 2, child: Text('NAME', style: labelStyle)),
          Expanded(
            flex: 2,
            child: Text(
              'CODE',
              style: labelStyle,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(flex: 2, child: Text('ENDPOINT', style: labelStyle)),
          Expanded(flex: 3, child: Text('DESCRIPTION', style: labelStyle)),
          SizedBox(
            width: statusColumnWidth,
            child: Text(
              'STATUS',
              style: labelStyle,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: actionsColumnWidth),
        ],
      ),
    );
  }
}

class _ModuleTableRow extends StatelessWidget {
  const _ModuleTableRow({
    required this.slNo,
    required this.module,
    required this.zebra,
    required this.slNoColumnWidth,
    required this.statusColumnWidth,
    required this.actionsColumnWidth,
    required this.onDelete,
  });

  final int slNo;
  final ApplicationModule module;
  final bool zebra;
  final double slNoColumnWidth;
  final double statusColumnWidth;
  final double actionsColumnWidth;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: zebra ? AppColors.background.withValues(alpha: 0.4) : null,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: slNoColumnWidth,
            child: Text(
              '$slNo',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              module.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: module.code == null
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
                        '${module.code}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              module.endpoint ?? '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              module.description ?? '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(
            width: statusColumnWidth,
            child: Align(
              alignment: Alignment.center,
              child: _StatusBadge(active: module.active),
            ),
          ),
          SizedBox(
            width: actionsColumnWidth,
            child: IconButton(
              tooltip: 'Delete module',
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
              onPressed: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? AppColors.gradientGreen.first.withValues(alpha: 0.12)
            : AppColors.textSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        active ? 'Active' : 'Inactive',
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: active ? AppColors.gradientGreen.first : AppColors.textSecondary,
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
            Icons.widgets_outlined,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No application modules found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search or add a new module.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
