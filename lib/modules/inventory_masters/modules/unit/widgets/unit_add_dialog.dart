import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../../unique_quantity_code/models/unique_quantity_code.dart';
import '../../unique_quantity_code/viewModel/unique_quantity_code_view_model.dart';
import '../models/create_unit_request.dart';
import '../models/stock_unit_type.dart';

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

/// Dialog form for creating a new unit.
///
/// Pops a [CreateUnitRequest] on save.
class UnitAddDialog extends StatefulWidget {
  const UnitAddDialog({super.key});

  @override
  State<UnitAddDialog> createState() => _UnitAddDialogState();
}

class _UnitAddDialogState extends State<UnitAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  StockUnitType _unitType = StockUnitType.simple;
  UniqueQuantityCode? _uqc;
  double _uqcFieldWidth = 420;

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
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      CreateUnitRequest(
        name: _nameController.text.trim(),
        code: _codeController.text.trim().isEmpty
            ? null
            : _codeController.text.trim().toUpperCase(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        unitType: _unitType,
        uqcId: _uqc?.id,
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
            prefixIcon: Icon(Icons.pin_outlined),
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
                    prefixIcon: Icon(Icons.square_foot_rounded),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter a unit name'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_-]')),
                    _UpperCaseTextFormatter(),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Code (optional)',
                    hintText: 'e.g. PCS',
                    prefixIcon: Icon(Icons.tag_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<StockUnitType>(
                  initialValue: _unitType,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Unit type',
                    prefixIcon: Icon(Icons.category_outlined),
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
                const SizedBox(height: 20),
                const _SectionLabel('Notes'),
                const SizedBox(height: 8),
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
