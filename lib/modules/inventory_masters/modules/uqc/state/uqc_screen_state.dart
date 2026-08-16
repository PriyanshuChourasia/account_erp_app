import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/create_uqc_request.dart';
import '../models/update_uqc_request.dart';
import '../models/uqc.dart';
import '../screens/uqc_screen.dart';
import '../viewModel/uqc_view_model.dart';
import '../widgets/uqc_add_dialog.dart';
import '../widgets/uqc_card.dart';

/// State for [UqcScreen]. Kept out of the screen file to follow the
/// StatefulWidget split pattern.
class UqcScreenState extends State<UqcScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<UqcViewModel>().loadUqcs();
    });
  }

  Future<void> _openForm([Uqc? uqc]) async {
    final result = await showDialog<dynamic>(
      context: context,
      builder: (_) => UqcFormDialog(initialUqc: uqc),
    );
    if (result == null || !mounted) return;
    final viewModel = context.read<UqcViewModel>();
    if (result is UpdateUqcRequest) {
      await viewModel.updateUqc(result);
    } else if (result is CreateUqcRequest) {
      await viewModel.addUqc(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UqcViewModel>();
    final uqcs = viewModel.filteredUqcs;

    return Scaffold(
      appBar: AppBar(title: const Text('UQCs')),
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
                    onPressed: _openForm,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add UQC'),
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
                    : uqcs.isEmpty
                    ? const _EmptyState()
                    : LayoutBuilder(
                        builder: (context, constraints) =>
                            constraints.maxWidth >= 720
                            ? _UqcTable(
                                uqcs: uqcs,
                                onEdit: (id) => _openForm(
                                  uqcs.firstWhere((uqc) => uqc.id == id),
                                ),
                              )
                            : ListView.separated(
                                itemCount: uqcs.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final uqc = uqcs[index];
                                  return UqcCard(
                                    uqc: uqc,
                                    onEdit: () => _openForm(uqc),
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

/// Table view of UQCs for wide screens.
///
/// Built from flex-aligned rows instead of [DataTable] — same approach as
/// account_nature's table — so it fills the available width, scrolls
/// vertically when the list is long (with a header that stays pinned), and
/// gives the GST code its own badge treatment instead of flat text.
class _UqcTable extends StatelessWidget {
  const _UqcTable({required this.uqcs, required this.onEdit});

  static const _slNoColumnWidth = 56.0;
  static const _codeColumnWidth = 72.0;
  static const _statusColumnWidth = 84.0;

  final List<Uqc> uqcs;
  final ValueChanged<int> onEdit;

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
          const _UqcTableHeader(
            slNoColumnWidth: _slNoColumnWidth,
            codeColumnWidth: _codeColumnWidth,
            statusColumnWidth: _statusColumnWidth,
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: ListView.separated(
              itemCount: uqcs.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) => _UqcTableRow(
                slNo: index + 1,
                uqc: uqcs[index],
                zebra: index.isOdd,
                slNoColumnWidth: _slNoColumnWidth,
                codeColumnWidth: _codeColumnWidth,
                statusColumnWidth: _statusColumnWidth,
                onEdit: () => onEdit(uqcs[index].id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UqcTableHeader extends StatelessWidget {
  const _UqcTableHeader({
    required this.slNoColumnWidth,
    required this.codeColumnWidth,
    required this.statusColumnWidth,
  });

  final double slNoColumnWidth;
  final double codeColumnWidth;
  final double statusColumnWidth;

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
          Expanded(flex: 3, child: Text('NAME', style: labelStyle)),
          SizedBox(
            width: codeColumnWidth,
            child: Text('CODE', style: labelStyle),
          ),
          Expanded(flex: 2, child: Text('ALIAS', style: labelStyle)),
          Expanded(flex: 4, child: Text('DESCRIPTION', style: labelStyle)),
          SizedBox(
            width: statusColumnWidth,
            child: Text('STATUS', style: labelStyle),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _UqcTableRow extends StatelessWidget {
  const _UqcTableRow({
    required this.slNo,
    required this.uqc,
    required this.zebra,
    required this.slNoColumnWidth,
    required this.codeColumnWidth,
    required this.statusColumnWidth,
    required this.onEdit,
  });

  final int slNo;
  final Uqc uqc;
  final bool zebra;
  final double slNoColumnWidth;
  final double codeColumnWidth;
  final double statusColumnWidth;
  final VoidCallback onEdit;

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
            flex: 3,
            child: Text(
              uqc.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: codeColumnWidth,
            child: uqc.code == null
                ? Text(
                    '—',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                : Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        uqc.code!,
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
              uqc.alias ?? '—',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              uqc.description ?? '—',
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
              alignment: Alignment.centerLeft,
              child: _StatusBadge(isActive: uqc.isActive),
            ),
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              tooltip: 'Edit UQC',
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.edit_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              onPressed: onEdit,
            ),
          ),
        ],
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
            Icons.straighten_rounded,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No UQCs found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search or add a new UQC.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
