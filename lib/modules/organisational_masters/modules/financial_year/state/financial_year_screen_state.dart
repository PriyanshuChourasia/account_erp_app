import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/create_financial_year_request.dart';
import '../models/financial_year.dart';
import '../screens/financial_year_screen.dart';
import '../utils/date_helpers.dart';
import '../viewModel/financial_year_view_model.dart';
import '../widgets/financial_year_add_dialog.dart';
import '../widgets/financial_year_card.dart';

/// State for [FinancialYearScreen]. Kept out of the screen file to follow the
/// StatefulWidget split pattern.
class FinancialYearScreenState extends State<FinancialYearScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<FinancialYearViewModel>().loadFinancialYears();
    });
  }

  Future<void> _openAddDialog() async {
    final result = await showDialog<CreateFinancialYearRequest>(
      context: context,
      builder: (_) => const FinancialYearAddDialog(),
    );
    if (result == null || !mounted) return;
    await context.read<FinancialYearViewModel>().addFinancialYear(result);
  }

  Future<void> _setCurrent(FinancialYearViewModel viewModel, String id) async {
    FinancialYear? year;
    for (final candidate in viewModel.financialYears) {
      if (candidate.id == id) {
        year = candidate;
        break;
      }
    }
    if (year == null) return;
    final selectedYear = year;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Set as current year?'),
        content: Text(
          '${selectedYear.name} will become the fiscal year used for '
          'transactions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Set current'),
          ),
        ],
      ),
    );
    if (confirmed == true) await viewModel.setCurrentFinancialYear(year, true);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FinancialYearViewModel>();
    final financialYears = viewModel.filteredFinancialYears;

    return Scaffold(
      appBar: AppBar(title: const Text('Financial Years')),
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
                        hintText: 'Search by name, code, ID or dates...',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _openAddDialog,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add financial year'),
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
                    : financialYears.isEmpty
                    ? const _EmptyState()
                    : LayoutBuilder(
                        builder: (context, constraints) =>
                            constraints.maxWidth >= 760
                            ? _FinancialYearTable(
                                financialYears: financialYears,
                                onSetCurrent: (id) =>
                                    _setCurrent(viewModel, id),
                              )
                            : ListView.separated(
                                itemCount: financialYears.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final year = financialYears[index];
                                  return FinancialYearCard(
                                    financialYear: year,
                                    onSetCurrent: year.isCurrent
                                        ? null
                                        : () => _setCurrent(viewModel, year.id),
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

/// Table view of financial years for wide screens.
///
/// Built from flex-aligned rows instead of [DataTable] — same approach as
/// account_nature's and UQC's tables — so it fills the available width,
/// scrolls vertically when the list is long (with a header that stays
/// pinned), and gives the fiscal-year code its own badge treatment instead
/// of flat text.
class _FinancialYearTable extends StatelessWidget {
  const _FinancialYearTable({
    required this.financialYears,
    required this.onSetCurrent,
  });

  static const _slNoColumnWidth = 56.0;
  static const _codeColumnWidth = 72.0;
  static const _statusColumnWidth = 96.0;

  final List<FinancialYear> financialYears;
  final ValueChanged<String> onSetCurrent;

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
          const _FinancialYearTableHeader(
            slNoColumnWidth: _slNoColumnWidth,
            codeColumnWidth: _codeColumnWidth,
            statusColumnWidth: _statusColumnWidth,
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: ListView.separated(
              itemCount: financialYears.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) => _FinancialYearTableRow(
                slNo: index + 1,
                financialYear: financialYears[index],
                zebra: index.isOdd,
                slNoColumnWidth: _slNoColumnWidth,
                codeColumnWidth: _codeColumnWidth,
                statusColumnWidth: _statusColumnWidth,
                onSetCurrent: () => onSetCurrent(financialYears[index].id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancialYearTableHeader extends StatelessWidget {
  const _FinancialYearTableHeader({
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
          Expanded(flex: 3, child: Text('PERIOD', style: labelStyle)),
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

class _FinancialYearTableRow extends StatelessWidget {
  const _FinancialYearTableRow({
    required this.slNo,
    required this.financialYear,
    required this.zebra,
    required this.slNoColumnWidth,
    required this.codeColumnWidth,
    required this.statusColumnWidth,
    required this.onSetCurrent,
  });

  final int slNo;
  final FinancialYear financialYear;
  final bool zebra;
  final double slNoColumnWidth;
  final double codeColumnWidth;
  final double statusColumnWidth;
  final VoidCallback onSetCurrent;

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
              financialYear.name,
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
            child: financialYear.code == null
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
                        financialYear.code!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '${formatFinancialDateString(financialYear.startDate)} → '
              '${formatFinancialDateString(financialYear.endDate)}',
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
              child: financialYear.isCurrent
                  ? const _CurrentBadge()
                  : Text(
                      '—',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
            ),
          ),
          SizedBox(
            width: 40,
            child: financialYear.isCurrent
                ? const Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: AppColors.primary,
                  )
                : IconButton(
                    tooltip: 'Set as current year',
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.star_outline_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: onSetCurrent,
                  ),
          ),
        ],
      ),
    );
  }
}

class _CurrentBadge extends StatelessWidget {
  const _CurrentBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Current',
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
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
            Icons.calendar_month_rounded,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No financial years found',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search or add a new financial year.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
