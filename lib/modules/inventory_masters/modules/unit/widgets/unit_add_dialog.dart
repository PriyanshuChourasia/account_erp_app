import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../../unique_quantity_code/models/unique_quantity_code.dart';
import '../../unique_quantity_code/viewModel/unique_quantity_code_view_model.dart';
import '../models/create_stock_unit_request.dart';
import '../models/stock_unit_type.dart';
import '../models/unit.dart';
import '../viewModel/unit_view_model.dart';

/// Uppercases whatever the user types into a field.
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

/// Dialog form for creating a new stock unit.
///
/// Pops a [CreateStockUnitRequest] on save.
class UnitAddDialog extends StatefulWidget {
  const UnitAddDialog({super.key});

  @override
  State<UnitAddDialog> createState() => _UnitAddDialogState();
}

class _UnitAddDialogState extends State<UnitAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _symbolController = TextEditingController();
  final _conversionFactorController = TextEditingController(text: '1');
  final _decimalPlacesController = TextEditingController();
  StockUnitType _unitType = StockUnitType.simple;
  UniqueQuantityCode? _uqc;
  bool _isActive = true;
  Unit? _primaryUnit;
  Unit? _secondaryUnit;
  double _uqcFieldWidth = 420;
  String? _formError;

  @override
  void initState() {
    super.initState();
    final uqcViewModel = context.read<UniqueQuantityCodeViewModel>();
    if (uqcViewModel.uqcs.isEmpty && !uqcViewModel.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) uqcViewModel.loadUniqueQuantityCodes();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _conversionFactorController.dispose();
    _decimalPlacesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_unitType == StockUnitType.compound && _primaryUnit == null) {
      setState(() => _formError = 'Select a primary unit for a compound unit.');
      return;
    }
    setState(() => _formError = null);
    Navigator.of(context).pop(
      CreateStockUnitRequest(
        name: _nameController.text.trim(),
        symbol: _symbolController.text.trim().isEmpty
            ? null
            : _symbolController.text.trim().toUpperCase(),
        unitType: _unitType,
        uqcId: _uqc?.id,
        primaryUnitId: _unitType == StockUnitType.compound
            ? _primaryUnit?.id
            : null,
        secondaryUnitId: _unitType == StockUnitType.compound
            ? _secondaryUnit?.id
            : null,
        conversionFactor: _unitType == StockUnitType.compound
            ? (double.tryParse(_conversionFactorController.text.trim()) ?? 1)
            : null,
        decimalPlaces: int.tryParse(_decimalPlacesController.text.trim()),
        active: _isActive,
      ),
    );
  }

  List<UniqueQuantityCode> get _uqcOptions {
    final uqcs = context.read<UniqueQuantityCodeViewModel>().uqcs;
    return uqcs.isEmpty ? UniqueQuantityCode.demo : uqcs;
  }

  String _uqcLabel(UniqueQuantityCode uqc) =>
      uqc.code == null ? uqc.name : '${uqc.code} — ${uqc.name}';

  Widget _buildUniqueQuantityCodeField() {
    return Autocomplete<UniqueQuantityCode>(
      initialValue: TextEditingValue(
        text: _uqc == null ? '' : _uqcLabel(_uqc!),
      ),
      displayStringForOption: _uqcLabel,
      optionsBuilder: (TextEditingValue value) {
        final query = value.text.trim().toLowerCase();
        if (query.isEmpty) return _uqcOptions;
        return _uqcOptions
            .where(
              (uqc) =>
                  uqc.name.toLowerCase().contains(query) ||
                  (uqc.code?.toLowerCase().contains(query) ?? false),
            )
            .toList();
      },
      onSelected: (uqc) => setState(() => _uqc = uqc),
      fieldViewBuilder: (context, controller, focusNode, _) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'UQC (optional)',
            hintText: 'Search and select a UQC',
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
              constraints: BoxConstraints(maxWidth: _uqcFieldWidth),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: [
                  for (final uqc in options)
                    ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.straighten_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      title: Text(uqc.name),
                      subtitle: uqc.code != null ? Text(uqc.code!) : null,
                      onTap: () => onSelected(uqc),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Unit> get _unitOptions {
    final units = context.read<UnitViewModel>().units;
    return units.isEmpty ? Unit.demo : units;
  }

  Widget _buildUnitPicker({
    required String label,
    required Unit? value,
    required ValueChanged<Unit?> onChanged,
  }) {
    return Autocomplete<Unit>(
      initialValue: TextEditingValue(text: value?.name ?? ''),
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
      onSelected: (unit) => onChanged(unit),
      fieldViewBuilder: (context, controller, focusNode, _) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            hintText: 'Search and select a unit',
            suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
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
              constraints: BoxConstraints(maxWidth: _uqcFieldWidth),
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
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final dialogWidth = screenWidth < 480 ? screenWidth * 0.9 : 420.0;

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.square_foot_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Add unit'),
        ],
      ),
      content: SizedBox(
        width: dialogWidth,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SectionLabel('Details'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g. Piece',
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter a unit name'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _symbolController,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_-]')),
                    _UpperCaseTextFormatter(),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Symbol (optional)',
                    hintText: 'e.g. PCS',
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Switch(
                      value: _isActive,
                      onChanged: (value) => setState(() => _isActive = value),
                    ),
                    const SizedBox(width: 8),
                    const Text('Active'),
                  ],
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<StockUnitType>(
                  initialValue: _unitType,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Unit type',
                  ),
                  items: [
                    for (final type in StockUnitType.values)
                      DropdownMenuItem(
                        value: type,
                        child: Text(type.name.toUpperCase()),
                      ),
                  ],
                  onChanged: (value) =>
                      setState(() => _unitType = value ?? _unitType),
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, uqcConstraints) {
                    _uqcFieldWidth = uqcConstraints.maxWidth;
                    return _buildUniqueQuantityCodeField();
                  },
                ),
                if (_unitType == StockUnitType.compound) ...[
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      _uqcFieldWidth = constraints.maxWidth;
                      return _buildUnitPicker(
                        label: 'Primary unit',
                        value: _primaryUnit,
                        onChanged: (unit) =>
                            setState(() => _primaryUnit = unit),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      _uqcFieldWidth = constraints.maxWidth;
                      return _buildUnitPicker(
                        label: 'Secondary unit',
                        value: _secondaryUnit,
                        onChanged: (unit) =>
                            setState(() => _secondaryUnit = unit),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _conversionFactorController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Conversion factor',
                      hintText: 'e.g. 12',
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                TextFormField(
                  controller: _decimalPlacesController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                    signed: false,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Decimal places (0–4, optional)',
                    hintText: 'e.g. 2',
                  ),
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    if (parsed == null) return null;
                    if (parsed < 0 || parsed > 4) {
                      return 'Decimal places must be between 0 and 4';
                    }
                    return null;
                  },
                ),
                if (_formError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _formError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('Save'),
        ),
      ],
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
