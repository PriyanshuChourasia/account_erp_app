import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../../stock_category/models/stock_category.dart';
import '../../stock_category/viewModel/stock_category_view_model.dart';
import '../../stock_group/models/stock_group.dart';
import '../../stock_group/viewModel/stock_group_view_model.dart';
import '../../unit/models/unit.dart';
import '../../unit/viewModel/unit_view_model.dart';

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

/// Dialog form for creating a new stock item.
///
/// Pops a record with the entered fields on save. This is a lean scaffold —
/// only identity + classification fields (group/category/unit) are
/// collected for now; GST/HSN and opening-balance fields are not yet
/// modelled.
class StockItemAddDialog extends StatefulWidget {
  const StockItemAddDialog({super.key});

  @override
  State<StockItemAddDialog> createState() => _StockItemAddDialogState();
}

class _StockItemAddDialogState extends State<StockItemAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _aliasController = TextEditingController();
  final _descriptionController = TextEditingController();
  StockGroup? _group;
  StockCategory? _category;
  Unit? _unit;
  double _groupFieldWidth = 420;
  double _categoryFieldWidth = 420;
  double _unitFieldWidth = 420;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final groupViewModel = context.read<StockGroupViewModel>();
      if (groupViewModel.stockGroups.isEmpty && !groupViewModel.isLoading) {
        groupViewModel.loadStockGroups();
      }
      final categoryViewModel = context.read<StockCategoryViewModel>();
      if (categoryViewModel.stockCategories.isEmpty &&
          !categoryViewModel.isLoading) {
        categoryViewModel.loadStockCategories();
      }
      final unitViewModel = context.read<UnitViewModel>();
      if (unitViewModel.units.isEmpty && !unitViewModel.isLoading) {
        unitViewModel.loadUnits();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _aliasController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop((
      name: _nameController.text.trim(),
      alias: _aliasController.text.trim().isEmpty
          ? null
          : _aliasController.text.trim(),
      code: _codeController.text.trim().isEmpty
          ? null
          : _codeController.text.trim().toUpperCase(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      stockGroupId: _group?.id,
      stockCategoryId: _category?.id,
      unitId: _unit?.id,
    ));
  }

  List<StockGroup> get _groupOptions {
    final groups = context.read<StockGroupViewModel>().stockGroups;
    return groups.isEmpty ? StockGroup.demo : groups;
  }

  List<StockCategory> get _categoryOptions {
    final categories = context.read<StockCategoryViewModel>().stockCategories;
    return categories.isEmpty ? StockCategory.demo : categories;
  }

  List<Unit> get _unitOptions {
    final units = context.read<UnitViewModel>().units;
    return units.isEmpty ? Unit.demo : units;
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
              Icons.inventory_2_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Add stock item'),
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
                    hintText: 'e.g. A4 Copier Paper',
                    prefixIcon: Icon(Icons.inventory_2_rounded),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter an item name'
                      : null,
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Za-z0-9_-]'),
                          ),
                          _UpperCaseTextFormatter(),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Code (optional)',
                          hintText: 'e.g. PAP-A4',
                          prefixIcon: Icon(Icons.tag_rounded),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _aliasController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Alias (optional)',
                          prefixIcon: Icon(Icons.alternate_email_rounded),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const _SectionLabel('Classification'),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    _groupFieldWidth = constraints.maxWidth;
                    return _buildGroupField();
                  },
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    _categoryFieldWidth = constraints.maxWidth;
                    return _buildCategoryField();
                  },
                ),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (context, constraints) {
                    _unitFieldWidth = constraints.maxWidth;
                    return _buildUnitField();
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

  Widget _buildGroupField() {
    return Autocomplete<StockGroup>(
      initialValue: TextEditingValue(text: _group?.name ?? ''),
      displayStringForOption: (group) => group.name,
      optionsBuilder: (TextEditingValue value) {
        final query = value.text.trim().toLowerCase();
        if (query.isEmpty) return _groupOptions;
        return _groupOptions
            .where((group) => group.name.toLowerCase().contains(query))
            .toList();
      },
      onSelected: (group) => setState(() => _group = group),
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
              constraints: BoxConstraints(maxWidth: _groupFieldWidth),
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
  }

  Widget _buildCategoryField() {
    return Autocomplete<StockCategory>(
      initialValue: TextEditingValue(text: _category?.name ?? ''),
      displayStringForOption: (category) => category.name,
      optionsBuilder: (TextEditingValue value) {
        final query = value.text.trim().toLowerCase();
        if (query.isEmpty) return _categoryOptions;
        return _categoryOptions
            .where((category) => category.name.toLowerCase().contains(query))
            .toList();
      },
      onSelected: (category) => setState(() => _category = category),
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
              constraints: BoxConstraints(maxWidth: _categoryFieldWidth),
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
  }

  Widget _buildUnitField() {
    return Autocomplete<Unit>(
      initialValue: TextEditingValue(text: _unit?.name ?? ''),
      displayStringForOption: (unit) =>
          unit.code == null ? unit.name : '${unit.code} — ${unit.name}',
      optionsBuilder: (TextEditingValue value) {
        final query = value.text.trim().toLowerCase();
        if (query.isEmpty) return _unitOptions;
        return _unitOptions
            .where(
              (unit) =>
                  unit.name.toLowerCase().contains(query) ||
                  (unit.code?.toLowerCase().contains(query) ?? false),
            )
            .toList();
      },
      onSelected: (unit) => setState(() => _unit = unit),
      fieldViewBuilder: (context, controller, focusNode, _) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: 'Unit (optional)',
            hintText: 'Search and select a unit',
            prefixIcon: Icon(Icons.square_foot_outlined),
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
              constraints: BoxConstraints(maxWidth: _unitFieldWidth),
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
                      subtitle: unit.code != null ? Text(unit.code!) : null,
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
