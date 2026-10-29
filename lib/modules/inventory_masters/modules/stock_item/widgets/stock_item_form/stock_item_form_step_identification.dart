import 'package:flutter/material.dart;
import 'package:flutter/services.dart';

import '../../../../config/theme/app_theme.dart';
import '../../../../models/create_stock_item_request.dart';
import '../../../../models/stock_item.dart';
import '../../viewModel/stock_item_view_model.dart';

/// Step 6 of the stock item create wizard — identification.
///
/// Captures SKU, barcode, manufacture part no, article no and brand id (there
/// is no brand module yet, so the brand is a plain optional numeric field).
/// The draft is read from and written to via the [StockItemViewModel] only.
class StockItemFormStepIdentification extends StatefulWidget {
  const StockItemFormStepIdentification({
    super.key,
    required this.viewModel,
    required this.formKey,
  });

  final StockItemViewModel viewModel;
  final GlobalKey<FormState> formKey;

  @override
  State<StockItemFormStepIdentification> createState() =>
      _StockItemFormStepIdentificationState();
}

class _StockItemFormStepIdentificationState
    extends State<StockItemFormStepIdentification> {
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _manufacturePartNoController = TextEditingController();
  final _articleNoController = TextEditingController();
  final _brandIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _syncFromDraft();
  }

  @override
  void dispose() {
    _skuController.dispose();
    _barcodeController.dispose();
    _manufacturePartNoController.dispose();
    _articleNoController.dispose();
    _brandIdController.dispose();
    super.dispose();
  }

  void _syncFromDraft() {
    final draft = widget.viewModel.draft;
    _skuController.text = draft.sku ?? '';
    _barcodeController.text = draft.barcode ?? '';
    _manufacturePartNoController.text = draft.manufacturePartNo ?? '';
    _articleNoController.text = draft.articleNo ?? '';
    _brandIdController.text = draft.brandId?.toString() ?? '';
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
      openingQuantity: draft.openingQuantity,
      openingValue: draft.openingValue,
      currentQuantity: draft.currentQuantity,
      reorderLevel: draft.reorderLevel,
      minimumStock: draft.minimumStock,
      maximumStock: draft.maximumStock,
      barcode: _barcodeController.text.trim().isEmpty
          ? null
          : _barcodeController.text.trim(),
      hsn: draft.hsn,
      sac: draft.sac,
      manufacturePartNo: _manufacturePartNoController.text.trim().isEmpty
          ? null
          : _manufacturePartNoController.text.trim(),
      articleNo: _articleNoController.text.trim().isEmpty
          ? null
          : _articleNoController.text.trim(),
      sku: _skuController.text.trim().isEmpty
          ? null
          : _skuController.text.trim(),
      brandId: int.tryParse(_brandIdController.text.trim()),
      active: draft.active,
    );
  }

  bool validate() => widget.formKey.currentState?.validate() ?? true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionLabel('Identification'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _skuController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'SKU (optional)',
              prefixIcon: Icon(Icons.local_offer_rounded),
            ),
            onChanged: (_) => _writeDraft(),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _barcodeController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Barcode (optional)',
              prefixIcon: Icon(Icons.qr_code_rounded),
            ),
            onChanged: (_) => _writeDraft(),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _manufacturePartNoController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Manufacture part no (optional)',
              prefixIcon: Icon(Icons.factory_rounded),
            ),
            onChanged: (_) => _writeDraft(),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _articleNoController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Article no (optional)',
              prefixIcon: Icon(Icons.article_rounded),
            ),
            onChanged: (_) => _writeDraft(),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _brandIdController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: false,
              signed: false,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Brand ID (optional)',
              prefixIcon: Icon(Icons.business_rounded),
            ),
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
