import 'package:flutter/material.dart';

import '../../../../config/theme/app_theme.dart';
import '../../../../models/create_stock_item_request.dart';
import '../../../../models/stock_item_type.dart';
import '../../../../viewModel/stock_item_view_model.dart';

/// Step 1 of the stock item create wizard — basic details.
///
/// Owns the `name` (required), `code`, `alias`, `description`, `stockItemType`
/// and `active` fields of the draft. The draft is read from and written to via
/// the [StockItemViewModel] only.
class StockItemFormStepBasicDetails extends StatefulWidget {
  const StockItemFormStepBasicDetails({
    super.key,
    required this.viewModel,
    required this.formKey,
  });

  final StockItemViewModel viewModel;
  final GlobalKey<FormState> formKey;

  @override
  State<StockItemFormStepBasicDetails> createState() =>
      _StockItemFormStepBasicDetailsState();
}

class _StockItemFormStepBasicDetailsState
    extends State<StockItemFormStepBasicDetails> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _aliasController = TextEditingController();
  final _descriptionController = TextEditingController();

  StockItemType? _stockItemType;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    _syncFromDraft();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _aliasController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _syncFromDraft() {
    final draft = widget.viewModel.draft;
    _nameController.text = draft.name;
    _codeController.text = draft.code ?? '';
    _aliasController.text = draft.alias ?? '';
    _descriptionController.text = draft.description ?? '';
    _stockItemType = draft.stockItemType;
    _active = draft.active;
  }

  void _writeDraft() {
    final draft = widget.viewModel.draft;
    widget.viewModel.draft = CreateStockItemRequest(
      name: _nameController.text.trim(),
      code: _codeController.text.trim().isEmpty
          ? null
          : _codeController.text.trim().toUpperCase(),
      alias: _aliasController.text.trim().isEmpty
          ? null
          : _aliasController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      stockItemType: _stockItemType,
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
      barcode: draft.barcode,
      hsn: draft.hsn,
      sac: draft.sac,
      manufacturePartNo: draft.manufacturePartNo,
      articleNo: draft.articleNo,
      sku: draft.sku,
      brandId: draft.brandId,
      active: _active,
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
          const _SectionLabel('Basic details'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'e.g. A4 Copier Paper',
              prefixIcon: Icon(Icons.inventory_2_rounded),
            ),
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? 'Enter an item name' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_-]')),
            ],
            decoration: const InputDecoration(
              labelText: 'Code (optional)',
              hintText: 'e.g. PAP-A4',
              prefixIcon: Icon(Icons.tag_rounded),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _aliasController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Alias (optional)',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _descriptionController,
            textCapitalization: TextCapitalization.sentences,
            minLines: 3,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.notes_rounded),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<StockItemType>(
            initialValue: _stockItemType,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Stock item type',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: [
              for (final type in StockItemType.values)
                DropdownMenuItem(value: type, child: Text(type.name.toUpperCase())),
            ],
            onChanged: (value) {
              setState(() => _stockItemType = value);
              _writeDraft();
            },
          ),
          const SizedBox(height: 14),
          SwitchListTile(
            value: _active,
            onChanged: (value) {
              setState(() => _active = value);
              _writeDraft();
            },
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.power_settings_new_rounded),
            title: const Text('Active'),
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
