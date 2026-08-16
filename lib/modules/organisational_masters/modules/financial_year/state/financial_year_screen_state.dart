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

  Future<void> _setCurrent(FinancialYearViewModel viewModel, int id) async {
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .error
                        .withValues(alpha: 0.08),
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
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
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
                                                : () => _setCurrent(
                                                    viewModel, year.id),
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
class _FinancialYearTable extends StatelessWidget {
  const _FinancialYearTable({
    required this.financialYears,
    required this.onSetCurrent,
  });

  final List<FinancialYear> financialYears;
  final ValueChanged<int> onSetCurrent;

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
            DataColumn(label: Text('Period')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('')),
          ],
          rows: [
            for (final year in financialYears)
              DataRow(
                cells: [
                  DataCell(Text('${year.id}')),
                  DataCell(
                    Text(
                      year.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataCell(Text(year.code ?? '—')),
                  DataCell(
                    Text(
                      '${formatFinancialDateString(year.startDate)} → '
                      '${formatFinancialDateString(year.endDate)}',
                    ),
                  ),
                  DataCell(
                    year.isCurrent ? const _CurrentBadge() : const Text('—'),
                  ),
                  DataCell(
                    year.isCurrent
                        ? const Icon(
                            Icons.star_rounded,
                            size: 20,
                            color: AppColors.primary,
                          )
                        : IconButton(
                            tooltip: 'Set as current year',
                            icon: const Icon(
                              Icons.star_outline_rounded,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () => onSetCurrent(year.id),
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
