import 'package:flutter/material.dart';

import '../../../../config/theme/app_theme.dart';
import '../../../../models/create_stock_item_request.dart';
import '../../../stock_category/models/stock_category.dart';
import '../../../stock_category/viewModel/stock_category_view_model.dart';
import '../../../stock_group/models/stock_group.dart';
import '../../../stock_group/viewModel/stock_group_view_model.dart';
import '../../../unit/models/unit.dart';
import '../../../unit/viewModel/unit_view_model.dart';
import '../../viewModel/stock_item_view_model.dart';

/// Step 2 of the stock item create wizard — classification & units.
///
/// Picks the stock group, stock category, required unit (displayed as
/// "symbol — name") and optional alternate unit. The draft is read from and
/// written to via the [StockItemViewModel] only.
class StockItemFormStepClassification extends StatefulWidget {
  const StockItemFormStepClassification({
    super.key,
    required this.viewModel,
    required this.formKey,
  });

  final StockItemViewModel viewModel;
  final GlobalKey<FormState> formKey;

  @override
  State<StockItemFormStepClassification> createState() =>
      _StockItemFormStepClassificationState();
}

class _StockItemFormStepClassificationState
    extends State<StockItemFormStepClassification> {
  StockGroup? _stockGroup;
  StockCategory? _stockCategory;
  Unit? _unit;
  Unit? _altUnit;

  double _fieldWidth = 420;

  List<StockGroup> get _stockGroupOptions {
    final groups = context.read<StockGroupViewModel>().stockGroups;
    return groups.isEmpty ? StockGroup.demo : groups;
  }

  List<StockCategory> get _stockCategoryOptions {
    final categories = context.read<StockCategoryViewModel>().stockCategories;
    return categories.isEmpty ? StockCategory.demo : categories;
  }

  List<Unit> get _unitOptions {
    final units = context.read<UnitViewModel>().units;
    return units.isEmpty ? Unit.demo : units;
  }

  void _syncFromDraft() {
    final draft = widget.viewModel.draft;
    _stockGroup = _stockGroupOptions
        .where((group) => group.id == draft.stockGroupId)
        .firstOrNull;
    _stockCategory = _stockCategoryOptions
        .where((category) => category.id == draft.stockCategoryId)
        .firstOrNull;
    _unit = _unitOptions.where((unit) => unit.id == draft.unitId).firstOrNull;
    _altUnit = _unitOptions
        .where((unit) => unit.id == draft.altUnitId)
        .firstOrNull;
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
      stockGroupId: _stockGroup?.id,
      stockCategoryId: _stockCategory?.id,
      unitId: _unit?.id ?? '',
      altUnitId: _altUnit?.id,
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
      active: draft.active,
    );
  }

  bool validate() => widget.formKey.currentState?.validate() ?? true;

  @override
  void initState() {
    super.initState();
    _syncFromDraft();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionLabel('Classification'),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              _fieldWidth = constraints.maxWidth;
              return Autocomplete<StockGroup>(
                initialValue: TextEditingValue(text: _stockGroup?.name ?? ''),
                displayStringForOption: (group) => group.name,
                optionsBuilder: (TextEditingValue value) {
                  final query = value.text.trim().toLowerCase();
                  if (query.isEmpty) return _stockGroupOptions;
                  return _stockGroupOptions
                      .where(
                        (group) =>
                            group.name.toLowerCase().contains(query) ||
                            (group.code?.toLowerCase().contains(query) ?? false),
                      )
                      .toList();
                },
                onSelected: (group) {
                  setState(() => _stockGroup = group);
                  _writeDraft();
                },
                fieldViewBuilder: (context, controller, focusNode, _) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Stock group (optional)',
                      hintText: 'Search and select a stock group',
                      prefixIcon: Icon(Icons.folder_outlined),
                      suffixIcon: Icon(Icons.arrow_drop_down_rounded),
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: _fieldWidth),
                        child: ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          children: [
                            for (final group in options)
                              ListTile(
                                dense: true,
                                leading: const Icon(
                                  Icons.folder_rounded,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                                title: Text(group.name),
                                subtitle: group.code != null ? Text(group.code!) : null,
                                onTap: () => onSelected(group),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              _fieldWidth = constraints.maxWidth;
              return Autocomplete<StockCategory>(
                initialValue: TextEditingValue(text: _stockCategory?.name ?? ''),
                displayStringForOption: (category) => category.name,
                optionsBuilder: (TextEditingValue value) {
                  final query = value.text.trim().toLowerCase();
                  if (query.isEmpty) return _stockCategoryOptions;
                  return _stockCategoryOptions
                      .where(
                        (category) =>
                            category.name.toLowerCase().contains(query) ||
                            (category.code?.toLowerCase().contains(query) ?? false),
                      )
                      .toList();
                },
                onSelected: (category) {
                  setState(() => _stockCategory = category);
                  _writeDraft();
                },
                fieldViewBuilder: (context, controller, focusNode, _) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Stock category (optional)',
                      hintText: 'Search and select a stock category',
                      prefixIcon: Icon(Icons.category_outlined),
                      suffixIcon: Icon(Icons.arrow_drop_down_rounded),
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: _fieldWidth),
                        child: ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          children: [
                            for (final category in options)
                              ListTile(
                                dense: true,
                                leading: const Icon(
                                  Icons.category_rounded,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                                title: Text(category.name),
                                subtitle: category.code != null
                                    ? Text(category.code!)
                                    : null,
                                onTap: () => onSelected(category),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              _fieldWidth = constraints.maxWidth;
              return Autocomplete<Unit>(
                initialValue: TextEditingValue(text: _unit?.name ?? ''),
                displayStringForOption: (unit) =>
                    unit.symbol == null ? unit.name : '${unit.symbol} — ${unit.name}',
                optionsBuilder: (TextEditingValue value) {
                  final query = value.text.trim().toLowerCase();
                  if (query.isEmpty) return _unitOptions;
                  return _unitOptions
                      .where(
                        (unit) =>
                            unit.name.toLowerCase().contains(query) ||
                            (unit.symbol?.toLowerCase().contains(query) ?? false),
                      )
                      .toList();
                },
                onSelected: (unit) {
                  setState(() => _unit = unit);
                  _writeDraft();
                },
                fieldViewBuilder: (context, controller, focusNode, _) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Unit (required)',
                      hintText: 'Search and select a unit',
                      prefixIcon: Icon(Icons.square_foot_rounded),
                      suffixIcon: Icon(Icons.arrow_drop_down_rounded),
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: _fieldWidth),
                        child: ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          children: [
                            for (final unit in options)
                              ListTile(
                                dense: true,
                                leading: const Icon(
                                  Icons.square_foot_rounded,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                                title: Text(unit.name),
                                subtitle: unit.symbol != null ? Text(unit.symbol!) : null,
                                onTap: () => onSelected(unit),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              _fieldWidth = constraints.maxWidth;
              return Autocomplete<Unit>(
                initialValue: TextEditingValue(text: _altUnit?.name ?? ''),
                displayStringForOption: (unit) =>
                    unit.symbol == null ? unit.name : '${unit.symbol} — ${unit.name}',
                optionsBuilder: (TextEditingValue value) {
                  final query = value.text.trim().toLowerCase();
                  if (query.isEmpty) return _unitOptions;
                  return _unitOptions
                      .where(
                        (unit) =>
                            unit.name.toLowerCase().contains(query) ||
                            (unit.symbol?.toLowerCase().contains(query) ?? false),
                      )
                      .toList();
                },
                onSelected: (unit) {
                  setState(() => _altUnit = unit);
                  _writeDraft();
                },
                fieldViewBuilder: (context, controller, focusNode, _) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Alternate unit (optional)',
                      hintText: 'Search and select an alternate unit',
                      prefixIcon: Icon(Icons.swap_horiz_rounded),
                      suffixIcon: Icon(Icons.arrow_drop_down_rounded),
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: _fieldWidth),
                        child: ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          children: [
                            for (final unit in options)
                              ListTile(
                                dense: true,
                                leading: const Icon(
                                  Icons.swap_horiz_rounded,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                                title: Text(unit.name),
                                subtitle: unit.symbol != null ? Text(unit.symbol!) : null,
                                onTap: () => onSelected(unit),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
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
