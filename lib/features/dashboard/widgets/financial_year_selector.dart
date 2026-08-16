import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme/app_theme.dart';
import '../../../modules/organisational_masters/modules/financial_year/models/create_financial_year_request.dart';
import '../../../modules/organisational_masters/modules/financial_year/models/financial_year.dart';
import '../../../modules/organisational_masters/modules/financial_year/viewModel/financial_year_view_model.dart';
import '../../../modules/organisational_masters/modules/financial_year/widgets/financial_year_add_dialog.dart';

/// Compact financial year picker shown in the dashboard header.
///
/// Loads the financial years on first build (when the module screen has not
/// been visited yet), lets the user switch the year used app-wide, and offers
/// a shortcut to create a new year. The selection lives in
/// [FinancialYearViewModel].
class FinancialYearSelector extends StatefulWidget {
  const FinancialYearSelector({super.key});

  @override
  State<FinancialYearSelector> createState() => _FinancialYearSelectorState();
}

class _FinancialYearSelectorState extends State<FinancialYearSelector> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final viewModel = context.read<FinancialYearViewModel>();
      if (viewModel.financialYears.isEmpty && !viewModel.isLoading) {
        viewModel.loadFinancialYears();
      }
    });
  }

  Future<void> _openCreateDialog() async {
    final result = await showDialog<CreateFinancialYearRequest>(
      context: context,
      builder: (_) => const FinancialYearAddDialog(),
    );
    if (result == null || !mounted) return;
    await context.read<FinancialYearViewModel>().addFinancialYear(result);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FinancialYearViewModel>();
    final selected = viewModel.selectedFinancialYear;

    if (viewModel.isLoading && viewModel.financialYears.isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          _AddYearButton(onPressed: _openCreateDialog),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (viewModel.financialYears.isEmpty)
          _NoYearsLabel()
        else
          PopupMenuButton<FinancialYear>(
            tooltip: 'Select financial year',
            onSelected: viewModel.selectFinancialYear,
            color: Colors.white,
            itemBuilder: (context) => [
              for (final year in viewModel.financialYears)
                PopupMenuItem<FinancialYear>(
                  value: year,
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 18,
                        color: year.id == selected?.id
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(year.name)),
                      if (year.id == selected?.id)
                        const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ),
            ],
            child: _SelectorButton(label: selected?.name ?? 'Financial year'),
          ),
        const SizedBox(width: 4),
        _AddYearButton(onPressed: _openCreateDialog),
      ],
    );
  }
}

class _AddYearButton extends StatelessWidget {
  const _AddYearButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Add financial year',
      onPressed: onPressed,
      icon: const Icon(Icons.add_rounded, size: 20, color: AppColors.primary),
    );
  }
}

class _SelectorButton extends StatelessWidget {
  const _SelectorButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_month_rounded,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.arrow_drop_down_rounded,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _NoYearsLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.calendar_month_rounded,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          'No financial year',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
