import 'package:flutter/material.dart;
import 'package:flutter/services.dart';

import '../../../../config/theme/app_theme.dart';
import '../../../../models/create_stock_item_request.dart';
import '../../../../models/stock_item.dart';
import '../../viewModel/stock_item_view_model.dart';

/// Step 4 of the stock item create wizard — pricing.
///
/// Captures the purchase and selling prices (numeric, non-negative, two decimal
/// places). A non-blocking warning is surfaced when the selling price is lower
/// than the purchase price. The draft is read from and written to via the
/// [StockItemViewModel] only.
class StockItemFormStepPricing extends StatefulWidget {
  const StockItemFormStepPricing({
    super.key,
    required this.viewModel,
    required this.formKey,
  });

  final StockItemViewModel viewModel;
  final GlobalKey<FormState> formKey;

  @override
  State<StockItemFormStepPricing> createState() => _StockItemFormStepPricingState();
}

class _StockItemFormStepPricingState extends State<StockItemFormStepPricing> {
  final _purchasePriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _syncFromDraft();
  }

  @override
  void dispose() {
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    super.dispose();
  }

  void _syncFromDraft() {
    final draft = widget.viewModel.draft;
    _purchasePriceController.text = draft.purchasePrice?.toString() ?? '';
    _sellingPriceController.text = draft.sellingPrice?.toString() ?? '';
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
      purchasePrice: _parseDouble(_purchasePriceController),
      sellingPrice: _parseDouble(_sellingPriceController),
      openingQuantity: draft.openingQuantity,
      openingValue: draft.openingValue,
      currentQuantity: draft.currentQuantity,
      reorderLevel: draft.reorderLevel,
      minimumStock: draft.minimumStock,
      maximumStock: draft.maximumStock,
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

  String? _priceValidator(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final price = double.tryParse(value.trim());
    if (price == null || price < 0) return 'Enter a price greater than or equal to 0.';
    if (price != (price * 100).roundToDouble() / 100) return 'Prices support at most 2 decimals.';
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
          const _SectionLabel('Pricing'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _purchasePriceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
            ],
            decoration: const InputDecoration(
              labelText: 'Purchase price',
              prefixIcon: Icon(Icons.shopping_cart_rounded),
            ),
            validator: _priceValidator,
            onChanged: (_) => _writeDraft(),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _sellingPriceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
            ],
            decoration: const InputDecoration(
              labelText: 'Selling price',
              prefixIcon: Icon(Icons.attach_money_rounded),
            ),
            validator: _priceValidator,
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
