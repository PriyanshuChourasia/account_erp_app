import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/create_department_request.dart';
import '../models/department.dart';
import '../screens/department_screen.dart';
import '../viewModel/department_view_model.dart';
import '../widgets/department_add_dialog.dart';
import '../widgets/department_card.dart';

/// State for [DepartmentScreen]. Kept out of the screen file to follow the
/// StatefulWidget split pattern.
class DepartmentScreenState extends State<DepartmentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<DepartmentViewModel>().loadDepartments();
    });
  }

  Future<void> _openAddDialog() async {
    final result = await showDialog<CreateDepartmentRequest>(
      context: context,
      builder: (_) => const DepartmentAddDialog(),
    );
    if (result == null || !mounted) return;
    await context.read<DepartmentViewModel>().addDepartment(result);
  }

  Future<void> _openEditDialog(Department department) async {
    final result = await showDialog<CreateDepartmentRequest>(
      context: context,
      builder: (_) => DepartmentAddDialog(initialDepartment: department),
    );
    if (result == null || !mounted) return;
    await context.read<DepartmentViewModel>().updateDepartment(
      department.id,
      result,
    );
  }

  Future<void> _confirmDelete(DepartmentViewModel viewModel, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete department?'),
        content: const Text(
          'This will remove the department from your master.',
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
    if (confirmed == true) await viewModel.deleteDepartment(id);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DepartmentViewModel>();
    // On phones the add button collapses to an icon so search keeps room.
    final isNarrow = MediaQuery.sizeOf(context).width < 600;
    final departments = viewModel.filteredDepartments;

    return Scaffold(
      appBar: AppBar(title: const Text('Departments')),
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
                  IconButton(
                    tooltip: 'Refresh departments',
                    // Always re-fetches from the service; no cached list is
                    // reused.
                    onPressed: viewModel.isLoading
                        ? null
                        : () => context
                              .read<DepartmentViewModel>()
                              .loadDepartments(),
                    icon: viewModel.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh_rounded),
                  ),
                  const SizedBox(width: 8),
                  if (isNarrow)
                    IconButton.filled(
                      tooltip: 'Add department',
                      onPressed: _openAddDialog,
                      icon: const Icon(Icons.add_rounded),
                    )
                  else
                    FilledButton.icon(
                      onPressed: _openAddDialog,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add department'),
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
                child: viewModel.isLoading && viewModel.departments.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : departments.isEmpty
                    ? const _EmptyState()
                    : LayoutBuilder(
                        builder: (context, constraints) =>
                            constraints.maxWidth >= 720
                            ? _DepartmentTable(
                                viewModel: viewModel,
                                onEdit: _openEditDialog,
                                onDelete: (id) => _confirmDelete(viewModel, id),
                              )
                            : Column(
                                children: [
                                  Expanded(
                                    child: ListView.separated(
                                      itemCount:
                                          viewModel.pagedDepartments.length,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(height: 10),
                                      itemBuilder: (context, index) {
                                        final department =
                                            viewModel.pagedDepartments[index];
                                        return DepartmentCard(
                                          department: department,
                                          isToggling: viewModel.isToggling(
                                            department.id,
                                          ),
                                          onActiveChanged: (value) => viewModel
                                              .setActive(department, value),
                                          onEdit: () =>
                                              _openEditDialog(department),
                                          onDelete: () => _confirmDelete(
                                            viewModel,
                                            department.id,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _Pager(viewModel: viewModel),
                                ],
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

/// Paginated table view of departments for wide screens. Stretches to the
/// full available width; only scrolls horizontally when the columns can't
/// fit.
class _DepartmentTable extends StatelessWidget {
  const _DepartmentTable({
    required this.viewModel,
    required this.onEdit,
    required this.onDelete,
  });

  final DepartmentViewModel viewModel;
  final ValueChanged<Department> onEdit;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final departments = viewModel.pagedDepartments;
    final firstIndex = viewModel.page * viewModel.rowsPerPage;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columnSpacing: 24,
                      horizontalMargin: 20,
                      headingRowHeight: 48,
                      headingRowColor: const WidgetStatePropertyAll(
                        AppColors.primary,
                      ),
                      headingTextStyle: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                      columns: const [
                        DataColumn(label: Text('#')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Code')),
                        DataColumn(label: Text('Description')),
                        DataColumn(label: Text('Active')),
                        DataColumn(
                          label: Expanded(
                            child: Text('Actions', textAlign: TextAlign.end),
                          ),
                        ),
                      ],
                      rows: [
                        for (final (index, department) in departments.indexed)
                          DataRow(
                            color: WidgetStatePropertyAll(
                              index.isOdd ? AppColors.background : Colors.white,
                            ),
                            cells: [
                              DataCell(Text('${firstIndex + index + 1}')),
                              DataCell(
                                Text(
                                  department.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              DataCell(Text(department.code ?? '—')),
                              DataCell(
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 360,
                                  ),
                                  child: Text(
                                    department.description ?? '—',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                _ActiveSwitch(
                                  value: department.isActive,
                                  busy: viewModel.isToggling(department.id),
                                  onChanged: (value) =>
                                      viewModel.setActive(department, value),
                                ),
                              ),
                              DataCell(
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Edit department',
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 20,
                                          color: AppColors.textSecondary,
                                        ),
                                        onPressed: () => onEdit(department),
                                      ),
                                      IconButton(
                                        tooltip: 'Delete department',
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          size: 20,
                                          color: AppColors.textSecondary,
                                        ),
                                        onPressed: () =>
                                            onDelete(department.id),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: _Pager(viewModel: viewModel),
          ),
        ],
      ),
    );
  }
}

/// Active/inactive switch; shows a small spinner while the change is saved.
class _ActiveSwitch extends StatelessWidget {
  const _ActiveSwitch({
    required this.value,
    required this.busy,
    required this.onChanged,
  });

  final bool value;
  final bool busy;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    if (busy) {
      return const SizedBox(
        width: 52,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    return Switch(value: value, onChanged: onChanged);
  }
}

/// Footer with rows-per-page selector, range label and page navigation.
class _Pager extends StatelessWidget {
  const _Pager({required this.viewModel});

  final DepartmentViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = viewModel.filteredDepartments.length;
    final start = total == 0 ? 0 : viewModel.page * viewModel.rowsPerPage + 1;
    final end = (start - 1 + viewModel.pagedDepartments.length);
    final isFirst = viewModel.page == 0;
    final isLast = viewModel.page >= viewModel.pageCount - 1;
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: AppColors.textSecondary,
    );

    return Container(
      width: double.infinity,
      alignment: Alignment.centerRight,
      child: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Rows per page', style: labelStyle),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: viewModel.rowsPerPage,
                underline: const SizedBox.shrink(),
                isDense: true,
                items: [
                  for (final option in DepartmentViewModel.rowsPerPageOptions)
                    DropdownMenuItem(value: option, child: Text('$option')),
                ],
                onChanged: (value) {
                  if (value != null) viewModel.setRowsPerPage(value);
                },
              ),
            ],
          ),
          Text('$start–$end of $total', style: labelStyle),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'First page',
                icon: const Icon(Icons.first_page_rounded),
                onPressed: isFirst ? null : () => viewModel.setPage(0),
              ),
              IconButton(
                tooltip: 'Previous page',
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: isFirst
                    ? null
                    : () => viewModel.setPage(viewModel.page - 1),
              ),
              Text(
                'Page ${viewModel.page + 1} of ${viewModel.pageCount}',
                style: labelStyle,
              ),
              IconButton(
                tooltip: 'Next page',
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: isLast
                    ? null
                    : () => viewModel.setPage(viewModel.page + 1),
              ),
              IconButton(
                tooltip: 'Last page',
                icon: const Icon(Icons.last_page_rounded),
                onPressed: isLast
                    ? null
                    : () => viewModel.setPage(viewModel.pageCount - 1),
              ),
            ],
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
            'No departments found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search or add a new department.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
