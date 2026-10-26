import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../config/theme/app_theme.dart';
import '../../../../../../core/handlers/error_handler.dart';
import '../models/create_employee_category_request.dart';
import '../models/employee_category.dart';
import '../screens/employee_category_screen.dart';
import '../viewModel/employee_category_view_model.dart';
import '../widgets/employee_category_card.dart';
import '../widgets/employee_category_form.dart';

/// State for [EmployeeCategoryScreen]. Kept out of the screen file to follow the
/// StatefulWidget split pattern.
///
/// Split layout: the category form on the left (wider) and the list of categories
/// on the right. Below [_splitBreakpoint] the two stack vertically.
class EmployeeCategoryScreenState extends State<EmployeeCategoryScreen> {
  static const double _splitBreakpoint = 1000;

  /// The category currently loaded into the form for editing, if any.
  EmployeeCategory? _editing;

  /// Scrolls the stacked (narrow) layout, so picking a category to edit can
  /// bring the form above the list back into view.
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<EmployeeCategoryViewModel>().loadEmployeeCategories();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _startEdit(EmployeeCategory category) {
    setState(() => _editing = category);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<bool> _submit(CreateEmployeeCategoryRequest request) async {
    final viewModel = context.read<EmployeeCategoryViewModel>();
    final editing = _editing;
    final saved = editing == null
        ? await viewModel.addEmployeeCategory(request)
        : await viewModel.updateEmployeeCategory(editing.id, request);
    if (!mounted) return saved;
    if (saved) {
      ErrorHandler.showMessage(
        context,
        editing == null
            ? 'Employee category added.'
            : 'Employee category updated.',
      );
      setState(() => _editing = null);
    }
    return saved;
  }

  Future<void> _confirmDelete(
    EmployeeCategoryViewModel viewModel,
    EmployeeCategory category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete employee category?'),
        content: Text('This will remove "${category.name}" from your master.'),
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
    if (confirmed != true) return;
    final deleted = await viewModel.deleteEmployeeCategory(category.id);
    if (deleted && _editing?.id == category.id && mounted) {
      setState(() => _editing = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EmployeeCategoryViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Employee Categories')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSplit = constraints.maxWidth >= _splitBreakpoint;
            final padding = constraints.maxWidth < 600 ? 16.0 : 20.0;

            final formPanel = _Panel(
              child: EmployeeCategoryForm(
                editing: _editing,
                onSubmit: _submit,
                onCancelEdit: () => setState(() => _editing = null),
              ),
            );
            final listPanel = _ListPanel(
              viewModel: viewModel,
              selectedId: _editing?.id,
              scrollable: isSplit,
              onEdit: _startEdit,
              onDelete: (category) => _confirmDelete(viewModel, category),
            );
            final error = viewModel.error == null
                ? null
                : _ErrorBanner(message: viewModel.error!);

            if (isSplit) {
              return Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (error != null) ...[error, const SizedBox(height: 16)],
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // The form side is the wider of the two.
                          Expanded(
                            flex: 3,
                            child: SingleChildScrollView(child: formPanel),
                          ),
                          const SizedBox(width: 20),
                          Expanded(flex: 2, child: listPanel),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            // Narrow screens: form on top, list below, whole page scrolls.
            return SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (error != null) ...[error, const SizedBox(height: 16)],
                  formPanel,
                  const SizedBox(height: 16),
                  listPanel,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// White bordered container shared by both halves of the screen.
class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }
}

/// Right-hand panel: header with count, search field and the category list.
class _ListPanel extends StatelessWidget {
  const _ListPanel({
    required this.viewModel,
    required this.selectedId,
    required this.scrollable,
    required this.onEdit,
    required this.onDelete,
  });

  final EmployeeCategoryViewModel viewModel;
  final String? selectedId;

  /// True in the split layout, where the list scrolls inside the panel;
  /// false when stacked, where the whole page scrolls instead.
  final bool scrollable;
  final ValueChanged<EmployeeCategory> onEdit;
  final ValueChanged<EmployeeCategory> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = viewModel.filteredEmployeeCategories;

    final Widget body;
    if (viewModel.isLoading) {
      body = const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (categories.isEmpty) {
      body = const _EmptyState();
    } else {
      body = ListView.separated(
        shrinkWrap: !scrollable,
        physics: scrollable ? null : const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          return EmployeeCategoryCard(
            category: category,
            selected: category.id == selectedId,
            onEdit: () => onEdit(category),
            onDelete: () => onDelete(category),
          );
        },
      );
    }

    return _Panel(
      child: Column(
        mainAxisSize: scrollable ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Employee categories (${viewModel.employeeCategories.length})',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: viewModel.setQuery,
            decoration: const InputDecoration(
              hintText: 'Search by name or alias...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 12),
          if (scrollable) Expanded(child: body) else body,
        ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
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
            'No employee categories found',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search or add one using the form.',
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
