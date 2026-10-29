import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_theme.dart';
import '../../../../models/create_stock_item_request.dart';
import '../../../../models/stock_item.dart';
import '../../../../models/stock_item_type.dart';
import '../../../../models/type_of_supply.dart';
import '../../../unit/viewModel/unit_view_model.dart';
import '../../viewModel/stock_item_view_model.dart';

/// Step 7 of the stock item create wizard — read-only review.
///
/// Summarises the draft grouped by the logical section it belongs to and offers
/// an "Edit" link per group that jumps back to the corresponding step. The
/// draft is read via the [StockItemViewModel] only.
class StockItemFormStepReview extends StatefulWidget {
  const StockItemFormStepReview({
    super.key,
    required this.viewModel,
    required this.formKey,
    required this.onEditStep,
  });

  final StockItemViewModel viewModel;
  final GlobalKey<FormState> formKey;
  final ValueChanged<int> onEditStep;

  @override
  State<StockItemFormStepReview> createState() => _StockItemFormStepReviewState();
}

class _StockItemFormStepReviewState extends State<StockItemFormStepReview> {
  @override
  Widget build(BuildContext context) {
    final draft = widget.viewModel.draft;
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionLabel('Review'),
          const SizedBox(height: 8),
          _buildGroup(
            context,
            title: 'Basic details',
            stepIndex: 0,
            onEditStep: widget.onEditStep,
            children: [
              _buildRow(context, 'Name', draft.name),
              _buildRow(context, 'Code', draft.code),
              _buildRow(context, 'Alias', draft.alias),
              _buildRow(context, 'Description', draft.description),
              _buildRow(
                context,
                'Stock item type',
                draft.stockItemType?.name.toUpperCase(),
              ),
              _buildRow(context, 'Active', draft.active ? 'Yes' : 'No'),
            ],
          ),
          _buildGroup(
            context,
            title: 'Classification & units',
            stepIndex: 1,
            onEditStep: widget.onEditStep,
            children: [
              _buildRow(context, 'Stock group', draft.stockGroupId),
              _buildRow(context, 'Stock category', draft.stockCategoryId),
              _buildRow(
                context,
                'Unit',
                draft.unitId.isEmpty ? null : _unitLabel(context, draft.unitId),
              ),
              _buildRow(
                context,
                'Alternate unit',
                draft.altUnitId == null ? null : _unitLabel(context, draft.altUnitId!),
              ),
            ],
          ),
          _buildGroup(
            context,
            title: 'Tax / GST',
            stepIndex: 2,
            onEditStep: widget.onEditStep,
            children: [
              _buildRow(context, 'Type of supply', draft.typeOfSupply?.name.toUpperCase()),
              _buildRow(context, 'GST rate', draft.gstRate?.toString()),
              _buildRow(context, 'HSN', draft.hsn),
              _buildRow(context, 'SAC', draft.sac),
            ],
          ),
          _buildGroup(
            context,
            title: 'Pricing',
            stepIndex: 3,
            onEditStep: widget.onEditStep,
            children: [
              _buildRow(context, 'Purchase price', draft.purchasePrice?.toString()),
              _buildRow(context, 'Selling price', draft.sellingPrice?.toString()),
            ],
          ),
          _buildGroup(
            context,
            title: 'Stock levels',
            stepIndex: 4,
            onEditStep: widget.onEditStep,
            children: [
              _buildRow(context, 'Opening quantity', draft.openingQuantity?.toString()),
              _buildRow(context, 'Opening value', draft.openingValue?.toString()),
              _buildRow(context, 'Reorder level', draft.reorderLevel?.toString()),
              _buildRow(context, 'Minimum stock', draft.minimumStock?.toString()),
              _buildRow(context, 'Maximum stock', draft.maximumStock?.toString()),
            ],
          ),
          _buildGroup(
            context,
            title: 'Identification',
            stepIndex: 5,
            onEditStep: widget.onEditStep,
            children: [
              _buildRow(context, 'SKU', draft.sku),
              _buildRow(context, 'Barcode', draft.barcode),
              _buildRow(context, 'Manufacture part no', draft.manufacturePartNo),
              _buildRow(context, 'Article no', draft.articleNo),
              _buildRow(context, 'Brand ID', draft.brandId?.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(
    BuildContext context, {
    required String title,
    required int stepIndex,
    required ValueChanged<int> onEditStep,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => onEditStep(stepIndex),
                child: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value == null || value.isEmpty ? '—' : value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
  }

  String? _unitLabel(BuildContext context, String unitId) {
    final units = context.read<UnitViewModel>().units;
    for (final unit in units) {
      if (unit.id == unitId) {
        return unit.symbol == null ? unit.name : '${unit.symbol} — ${unit.name}';
      }
    }
    return unitId;
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );
  }
}
