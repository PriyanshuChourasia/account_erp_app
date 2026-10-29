import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/theme/app_theme.dart';
import '../../../../models/create_stock_item_request.dart';
import '../../../../models/type_of_supply.dart';
import '../../viewModel/stock_item_view_model.dart';

/// Step 3 of the stock item create wizard — tax / GST.
///
/// Picks the type of supply, GST rate and the HSN/SAC identifiers. The draft is
/// read from and written to via the [StockItemViewModel] only.
class StockItemFormStepTax extends StatefulWidget {
  const StockItemFormStepTax({
    super.key,
    required this.viewModel,
    required this.formKey,
  });

  final StockItemViewModel viewModel;
  final GlobalKey<FormState> formKey;

  @override
  State<StockItemFormStepTax> createState() => _StockItemFormStepTaxState();
}

class _StockItemFormStepTaxState extends State<StockItemFormStepTax> {
  final _gstRateController = TextEditingController();
  final _hsnController = TextEditingController();
  final _sacController = TextEditingController();

  TypeOfSupply? _typeOfSupply;

  @override
  void initState() {
    super.initState();
    _syncFromDraft();
  }

  @override
  void dispose() {
    _gstRateController.dispose();
    _hsnController.dispose();
    _sacController.dispose();
    super.dispose();
  }

  void _syncFromDraft() {
    final draft = widget.viewModel.draft;
    _typeOfSupply = draft.typeOfSupply;
    _gstRateController.text = draft.gstRate?.toString() ?? '';
    _hsnController.text = draft.hsn ?? '';
    _sacController.text = draft.sac ?? '';
  }

  void _writeDraft() {
    final draft = widget.viewModel.draft;
    widget.viewModel.draft = CreateStockItemRequest(
      name: draft.name,
      code: draft.code,
      alias: draft.alias,
      description: draft.description,
      stockItemType: draft.stockItemType,
      typeOfSupply: _typeOfSupply,
      stockGroupId: draft.stockGroupId,
      stockCategoryId: draft.stockCategoryId,
      unitId: draft.unitId,
      altUnitId: draft.altUnitId,
      gstRate: _parseDouble(_gstRateController),
      purchasePrice: draft.purchasePrice,
      sellingPrice: draft.sellingPrice,
      openingQuantity: draft.openingQuantity,
      openingValue: draft.openingValue,
      currentQuantity: draft.currentQuantity,
      reorderLevel: draft.reorderLevel,
      minimumStock: draft.minimumStock,
      maximumStock: draft.maximumStock,
      barcode: draft.barcode,
      hsn: _hsnController.text.trim().isEmpty ? null : _hsnController.text.trim(),
      sac: _sacController.text.trim().isEmpty ? null : _sacController.text.trim(),
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

  bool validate() => widget.formKey.currentState?.validate() ?? true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionLabel('Tax / GST'),
          const SizedBox(height: 8),
          DropdownButtonFormField<TypeOfSupply>(
            initialValue: _typeOfSupply,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Type of supply',
              prefixIcon: Icon(Icons.swap_horiz_rounded),
            ),
            items: [
              for (final type in TypeOfSupply.values)
                DropdownMenuItem(value: type, child: Text(type.name.toUpperCase())),
            ],
            onChanged: (value) {
              setState(() => _typeOfSupply = value);
              _writeDraft();
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _gstRateController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'GST rate (%)',
              prefixIcon: Icon(Icons.percent_rounded),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;
              final rate = double.tryParse(value.trim());
              if (rate == null || rate < 0 || rate > 100) {
                return 'Enter a GST rate between 0 and 100.';
              }
              return null;
            },
            onChanged: (_) => _writeDraft(),
          ),
          const SizedBox(height: 14),
          if (_typeOfSupply == TypeOfSupply.goods) ...[
            TextFormField(
              controller: _hsnController,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                labelText: 'HSN (4, 6 or 8 digits)',
                prefixIcon: Icon(Icons.medical_services_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                if (value.trim().length < 4 || value.trim().length > 8) {
                  return 'HSN must be 4, 6 or 8 digits.';
                }
                return null;
              },
              onChanged: (_) => _writeDraft(),
            ),
            const SizedBox(height: 14),
          ],
          if (_typeOfSupply == TypeOfSupply.services) ...[
            TextFormField(
              controller: _sacController,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                labelText: 'SAC (6 digits)',
                prefixIcon: Icon(Icons.receipt_long_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                if (value.trim().length != 6) {
                  return 'SAC must be 6 digits.';
                }
                return null;
              },
              onChanged: (_) => _writeDraft(),
            ),
          ],
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
