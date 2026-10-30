import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../../../../../core/handlers/error_handler.dart';
import '../../stock_category/viewModel/stock_category_view_model.dart';
import '../../stock_group/viewModel/stock_group_view_model.dart';
import '../../unit/viewModel/unit_view_model.dart';
import '../models/create_stock_item_request.dart';
import '../models/stock_item_type.dart';
import '../models/type_of_supply.dart';
import '../screens/stock_item_form_screen.dart';
import '../viewModel/stock_item_view_model.dart';
import '../widgets/stock_item_form/form_section.dart';
import '../widgets/stock_item_form/key_value_row.dart';

/// State for [StockItemFormScreen]: a full-screen, single-page
/// `Label : value` entry form with the name block at the top left.
class StockItemFormScreenState extends State<StockItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  final _name = TextEditingController();
  final _alias = TextEditingController();
  final _code = TextEditingController();
  final _gstRate = TextEditingController();
  final _hsn = TextEditingController();
  final _sac = TextEditingController();
  final _purchasePrice = TextEditingController();
  final _sellingPrice = TextEditingController();
  final _barcode = TextEditingController();
  final _sku = TextEditingController();
  final _manufacturePartNo = TextEditingController();
  final _articleNo = TextEditingController();
  final _brandId = TextEditingController();
  final _openingQuantity = TextEditingController();
  final _openingValue = TextEditingController();
  final _currentQuantity = TextEditingController();
  final _reorderLevel = TextEditingController();
  final _minimumStock = TextEditingController();
  final _maximumStock = TextEditingController();

  String? _stockGroupId;
  String? _stockCategoryId;
  String? _parentId;
  String? _unitId;
  String? _altUnitId;
  StockItemType? _stockItemType;
  TypeOfSupply? _typeOfSupply;
  bool _active = true;

  List<TextEditingController> get _controllers => [
        _name, _alias, _code, _gstRate, _hsn, _sac, _purchasePrice,
        _sellingPrice, _barcode, _sku, _manufacturePartNo, _articleNo,
        _brandId, _openingQuantity, _openingValue, _currentQuantity,
        _reorderLevel, _minimumStock, _maximumStock,
      ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final groups = context.read<StockGroupViewModel>();
      final categories = context.read<StockCategoryViewModel>();
      final units = context.read<UnitViewModel>();
      final items = context.read<StockItemViewModel>();
      if (groups.stockGroups.isEmpty) groups.loadStockGroups();
      if (categories.stockCategories.isEmpty) categories.loadStockCategories();
      if (units.units.isEmpty) units.loadUnits();
      if (items.stockItems.isEmpty) items.loadStockItems();
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyS, meta: true): _save,
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): _save,
        const SingleActivator(LogicalKeyboardKey.escape): _cancel,
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(title: const Text('Stock Item Creation')),
        body: Form(
          key: _formKey,
          child: FocusTraversalGroup(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 900;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(wide),
                      const SizedBox(height: 16),
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildLeftColumn()),
                            const SizedBox(width: 48),
                            Expanded(child: _buildRightColumn()),
                          ],
                        )
                      else ...[
                        _buildLeftColumn(),
                        _buildRightColumn(),
                      ],
                      _buildStockSection(wide),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildActionBar(),
      ),
    );
  }

  // ── Layout blocks ──────────────────────────────────────────────────────────

  Widget _buildHeader(bool wide) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: wide ? 560 : double.infinity),
      child: Column(
        children: [
          KeyValueRow(
            label: 'Name',
            isRequired: true,
            child: TextFormField(
              controller: _name,
              autofocus: true,
              textInputAction: TextInputAction.next,
              style: const TextStyle(fontWeight: FontWeight.w600),
              decoration: _dense(),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Name is required' : null,
            ),
          ),
          KeyValueRow(label: 'Alias', child: _textField(_alias)),
          KeyValueRow(label: 'Code', child: _textField(_code)),
        ],
      ),
    );
  }

  Widget _buildLeftColumn() {
    final groups = context.watch<StockGroupViewModel>().stockGroups;
    final categories = context.watch<StockCategoryViewModel>().stockCategories;
    final items = context.watch<StockItemViewModel>().stockItems;
    final units = context.watch<UnitViewModel>().units;
    final unitOptions = {
      for (final unit in units)
        unit.id: unit.symbol == null ? unit.name : '${unit.symbol} — ${unit.name}',
    };

    return FormSection(
      title: 'General',
      children: [
        KeyValueRow(
          label: 'Under (Stock group)',
          child: _dropdown<String>(
            value: _stockGroupId,
            options: {for (final g in groups) g.id: g.name},
            onChanged: (v) => setState(() => _stockGroupId = v),
            allowNone: true,
          ),
        ),
        KeyValueRow(
          label: 'Category',
          child: _dropdown<String>(
            value: _stockCategoryId,
            options: {for (final c in categories) c.id: c.name},
            onChanged: (v) => setState(() => _stockCategoryId = v),
            allowNone: true,
          ),
        ),
        KeyValueRow(
          label: 'Parent item',
          child: _dropdown<String>(
            value: _parentId,
            options: {for (final i in items) i.id: i.name},
            onChanged: (v) => setState(() => _parentId = v),
            allowNone: true,
          ),
        ),
        KeyValueRow(
          label: 'Type',
          child: _dropdown<StockItemType>(
            value: _stockItemType,
            options: {
              StockItemType.goods: 'Goods',
              StockItemType.service: 'Service',
            },
            onChanged: (v) => setState(() => _stockItemType = v),
            allowNone: true,
          ),
        ),
        KeyValueRow(
          label: 'Units',
          isRequired: true,
          child: _dropdown<String>(
            value: _unitId,
            options: unitOptions,
            onChanged: (v) => setState(() => _unitId = v),
            validator: (v) => v == null ? 'Unit is required' : null,
          ),
        ),
        KeyValueRow(
          label: 'Alternate units',
          isRequired: true,
          child: _dropdown<String>(
            value: _altUnitId,
            options: unitOptions,
            onChanged: (v) => setState(() => _altUnitId = v),
            validator: (v) => v == null ? 'Alternate unit is required' : null,
          ),
        ),
        KeyValueRow(
          label: 'Active',
          child: Align(
            alignment: Alignment.centerLeft,
            child: Switch(
              value: _active,
              onChanged: (v) => setState(() => _active = v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormSection(
          title: 'Statutory details',
          children: [
            KeyValueRow(
              label: 'Type of supply',
              child: _dropdown<TypeOfSupply>(
                value: _typeOfSupply,
                options: {
                  TypeOfSupply.goods: 'Goods',
                  TypeOfSupply.services: 'Services',
                  TypeOfSupply.capitalGoods: 'Capital goods',
                },
                onChanged: (v) => setState(() => _typeOfSupply = v),
                allowNone: true,
              ),
            ),
            KeyValueRow(
              label: 'GST rate (%)',
              child: _numberField(
                _gstRate,
                validator: (v) {
                  if (v == null) return null;
                  return v > 100 ? 'GST rate must be between 0 and 100' : null;
                },
              ),
            ),
            if (_typeOfSupply == TypeOfSupply.goods)
              KeyValueRow(
                label: 'HSN',
                isRequired: true,
                child: _digitsField(
                  _hsn,
                  maxLength: 8,
                  validator: (v) => const [4, 6, 8].contains(v.length)
                      ? null
                      : 'HSN must be 4, 6 or 8 digits',
                ),
              ),
            if (_typeOfSupply == TypeOfSupply.services)
              KeyValueRow(
                label: 'SAC',
                isRequired: true,
                child: _digitsField(
                  _sac,
                  maxLength: 6,
                  validator: (v) => v.length == 6 ? null : 'SAC must be 6 digits',
                ),
              ),
          ],
        ),
        FormSection(
          title: 'Price details',
          children: [
            KeyValueRow(label: 'Purchase price', child: _numberField(_purchasePrice)),
            KeyValueRow(label: 'Selling price', child: _numberField(_sellingPrice)),
          ],
        ),
        FormSection(
          title: 'Identification',
          children: [
            KeyValueRow(label: 'Barcode', child: _textField(_barcode)),
            KeyValueRow(label: 'SKU', child: _textField(_sku)),
            KeyValueRow(label: 'Mfr part no', child: _textField(_manufacturePartNo)),
            KeyValueRow(label: 'Article no', child: _textField(_articleNo)),
            KeyValueRow(
              label: 'Brand id',
              child: TextFormField(
                controller: _brandId,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _dense(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStockSection(bool wide) {
    final fields = <Widget>[
      KeyValueRow(label: 'Opening qty', child: _numberField(_openingQuantity)),
      KeyValueRow(label: 'Opening value', child: _numberField(_openingValue)),
      KeyValueRow(label: 'Current qty', child: _numberField(_currentQuantity)),
      KeyValueRow(label: 'Reorder level', child: _numberField(_reorderLevel)),
      KeyValueRow(label: 'Min stock', child: _numberField(_minimumStock)),
      KeyValueRow(
        label: 'Max stock',
        child: _numberField(
          _maximumStock,
          validator: (max) {
            final min = _parse(_minimumStock);
            return (max != null && min != null && max < min)
                ? 'Max stock must be ≥ min stock'
                : null;
          },
        ),
      ),
    ];

    return FormSection(
      title: 'Stock levels & opening balance',
      children: [
        if (wide)
          for (var i = 0; i < fields.length; i += 3)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var j = i; j < i + 3; j++) ...[
                  Expanded(child: fields[j]),
                  if (j < i + 2) const SizedBox(width: 32),
                ],
              ],
            )
        else
          ...fields,
      ],
    );
  }

  Widget _buildActionBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _isSaving ? null : _cancel,
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(_isSaving ? 'Saving...' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Field helpers ──────────────────────────────────────────────────────────

  InputDecoration _dense({String? counterText}) => InputDecoration(
        isDense: true,
        counterText: counterText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: const OutlineInputBorder(),
      );

  Widget _textField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: _dense(),
    );
  }

  /// Non-negative decimal field. [validator] receives the parsed value.
  Widget _numberField(
    TextEditingController controller, {
    String? Function(double? value)? validator,
  }) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
      decoration: _dense(),
      validator: (_) => validator?.call(_parse(controller)),
    );
  }

  /// Digits-only field (HSN / SAC). [validator] receives the trimmed text.
  Widget _digitsField(
    TextEditingController controller, {
    required int maxLength,
    required String? Function(String value) validator,
  }) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      maxLength: maxLength,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: _dense(counterText: ''),
      validator: (value) => validator(value?.trim() ?? ''),
    );
  }

  Widget _dropdown<T>({
    required T? value,
    required Map<T, String> options,
    required ValueChanged<T?> onChanged,
    FormFieldValidator<T>? validator,
    bool allowNone = false,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: options.containsKey(value) ? value : null,
      isExpanded: true,
      decoration: _dense(),
      validator: validator,
      items: [
        if (allowNone) DropdownMenuItem<T>(value: null, child: const Text('— None —')),
        for (final entry in options.entries)
          DropdownMenuItem<T>(
            value: entry.key,
            child: Text(entry.value, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    );
  }

  double? _parse(TextEditingController controller) =>
      double.tryParse(controller.text.trim());

  String? _text(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void _cancel() {
    if (_isSaving) return;
    Navigator.of(context).maybePop();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final request = CreateStockItemRequest(
      name: _name.text.trim(),
      code: _text(_code),
      alias: _text(_alias),
      parentId: _parentId,
      stockItemType: _stockItemType,
      typeOfSupply: _typeOfSupply,
      stockGroupId: _stockGroupId,
      stockCategoryId: _stockCategoryId,
      unitId: _unitId!,
      altUnitId: _altUnitId!,
      gstRate: _parse(_gstRate),
      purchasePrice: _parse(_purchasePrice),
      sellingPrice: _parse(_sellingPrice),
      openingQuantity: _parse(_openingQuantity),
      openingValue: _parse(_openingValue),
      currentQuantity: _parse(_currentQuantity),
      reorderLevel: _parse(_reorderLevel),
      minimumStock: _parse(_minimumStock),
      maximumStock: _parse(_maximumStock),
      barcode: _text(_barcode),
      hsn: _typeOfSupply == TypeOfSupply.goods ? _text(_hsn) : null,
      sac: _typeOfSupply == TypeOfSupply.services ? _text(_sac) : null,
      manufacturePartNo: _text(_manufacturePartNo),
      articleNo: _text(_articleNo),
      sku: _text(_sku),
      brandId: int.tryParse(_brandId.text.trim()),
      active: _active,
    );

    setState(() => _isSaving = true);
    final viewModel = context.read<StockItemViewModel>();
    final ok = await viewModel.addStockItem(request);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (ok) {
      Navigator.of(context).pop();
    } else {
      ErrorHandler.showError(context, viewModel.error ?? 'Failed to save stock item');
    }
  }
}
