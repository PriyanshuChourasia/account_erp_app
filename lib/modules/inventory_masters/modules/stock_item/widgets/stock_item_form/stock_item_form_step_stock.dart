import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/theme/app_theme.dart';
import '../../../../models/create_stock_item_request.dart';
import '../../../../models/stock_item.dart';
import '../../viewModel/stock_item_view_model.dart';

/// Step 5 of the stock item create wizard — stock levels.
///
/// Captures opening quantity/value, reorder level, minimum and maximum stock.
/// The opening value auto-fills as opening quantity × purchase price (editable),
/// and the maximum stock must be ≥ the minimum stock. The draft is read from
/// and written to via the [StockItemViewModel] only.
class StockItemFormStepStock extends StatefulWidget {
  const StockItemFormStepStock({
    super.key,
    required this.viewModel,
    required this.formKey,
  });

  final StockItemViewModel viewModel;
  final GlobalKey<FormState> formKey;

  @override
  State<StockItemFormStepStock> createState() => _StockItemFormStepStockState();
}

class _StockItemFormStepStockState extends State<StockItemFormStepStock> {
  final _openingQuantityController = TextEditingController();
  final _openingValueController = TextEditingController();
  final _reorderLevelController = TextEditingController();
  final _minimumStockController = TextEditingController();
  final _maximumStockController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _syncFromDraft();
  }

  @override
  void dispose() {
    _openingQuantityController.dispose();
    _openingValueController.dispose();
    _reorderLevelController.dispose();
    _minimumStockController.dispose();
    _maximumStockController.dispose();
    super.dispose();
  }

  void _syncFromDraft() {
    final draft = widget.viewModel.draft;
    _openingQuantityController.text = draft.openingQuantity?.toString() ?? '';
    _openingValueController.text = draft.openingValue?.toString() ?? '';
    _reorderLevelController.text = draft.reorderLevel?.toString() ?? '';
    _minimumStockController.text = draft.minimumStock?.toString() ?? '';
    _maximumStockController.text = draft.maximumStock?.toString() ?? '';
  }

  void _writeDraft() {
    final draft = widget.viewModel.draft;
    widget.viewModel.draft = CreateStockItemRequest(
      name: draft.name,
      code: draft.code,
      alias: draft.alias,
      description: draft.description,
      stockItemType: draft.stockItemType,
      typeOfSupply: draft.typeOfSupply,
      stockGroupId: draft.stockGroupId,
      stockCategoryId: draft.stockCategoryId,
      unitId: draft.unitId,
      altUnitId: draft.altUnitId,
      gstRate: draft.gstRate,
      purchasePrice: draft.purchasePrice,
      sellingPrice: draft.sellingPrice,
      openingQuantity: _parseDouble(_openingQuantityController),
      openingValue: _parseDouble(_openingValueController),
      currentQuantity: draft.currentQuantity,
      reorderLevel: _parseDouble(_reorderLevelController),
      minimumStock: _parseDouble(_minimumStockController),
      maximumStock: _parseDouble(_maximumStockController),
      barcode: draft.barcode,
      hsn: draft.hsn,
      sac: draft.sac,
      manufacturePartNo: draft.manufacturePartNo,
      articleNo: draft.articleNo,
      sku: draft.sku,
      brandId: draft.brandId,
      active: draft.active,
    );
  }

  double? _parseDouble(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  void _onOpeningQuantityChanged(String value) {
    final quantity = _parseDouble(_openingQuantityController);
    final purchasePrice = widget.viewModel.draft.purchasePrice;
    if (quantity != null && purchasePrice != null) {
      final autoValue = quantity * purchasePrice;
      if (_openingValueController.text.trim().isEmpty) {
        _openingValueController.text = autoValue.toString();
      }
    }
    _writeDraft();
  }

  String? _nonNegativeValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final number = double.tryParse(value.trim());
    if (number == null || number < 0) return 'Enter a value greater than or equal to 0.';
    return null;
  }

  bool validate() => widget.formKey.currentState?.validate() ?? true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionLabel('Stock levels'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _openingQuantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Opening quantity',
              prefixIcon: Icon(Icons.inventory_2_rounded),
            ),
            validator: _nonNegativeValidator,
            onChanged: _onOpeningQuantityChanged,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _openingValueController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Opening value',
              prefixIcon: Icon(Icons.currency_rupee_rounded),
            ),
            validator: _nonNegativeValidator,
            onChanged: (_) => _writeDraft(),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _reorderLevelController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Reorder level',
              prefixIcon: Icon(Icons.trending_down_rounded),
            ),
            validator: _nonNegativeValidator,
            onChanged: (_) => _writeDraft(),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _minimumStockController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Minimum stock',
              prefixIcon: Icon(Icons.trending_down_rounded),
            ),
            validator: _nonNegativeValidator,
            onChanged: (_) => _writeDraft(),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _maximumStockController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Maximum stock',
              prefixIcon: Icon(Icons.trending_up_rounded),
            ),
            validator: (value) {
              final nonNegativeError = _nonNegativeValidator(value);
              if (nonNegativeError != null) return nonNegativeError;
              final minimum = _parseDouble(_minimumStockController);
              final maximum = _parseDouble(_maximumStockController);
              if (minimum != null && maximum != null && maximum < minimum) {
                return 'Maximum stock must be greater than or equal to the minimum stock.';
              }
              return null;
            },
            onChanged: (_) => _writeDraft(),
          ),
        ],
      ),
    );
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
