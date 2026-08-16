import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/create_stock_category_request.dart';
import '../models/stock_category.dart';
import '../viewModel/stock_category_view_model.dart';

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

/// Dialog form for creating a new stock category.
///
/// Pops a [CreateStockCategoryRequest] on save. The "Under" parent defaults to
/// Primary, which is the root — so it submits `null` as the parentId.
class StockCategoryAddDialog extends StatefulWidget {
  const StockCategoryAddDialog({super.key});

  @override
  State<StockCategoryAddDialog> createState() => _StockCategoryAddDialogState();
}

class _StockCategoryAddDialogState extends State<StockCategoryAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _aliasController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  StockCategory? _parent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final categories = context.read<StockCategoryViewModel>().stockCategories;
      if (categories.isEmpty) return;
      setState(() {
        _parent = categories
            .where((category) => category.name == 'Primary')
            .firstOrNull;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aliasController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final isPrimaryRoot = _parent?.name == 'Primary';
    Navigator.of(context).pop(
      CreateStockCategoryRequest(
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
        parentId: isPrimaryRoot ? null : _parent?.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<StockCategoryViewModel>().stockCategories;
    final options = categories.isEmpty ? StockCategory.demo : categories;

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
              Icons.category_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Add stock category'),
        ],
      ),
      content: Form(
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
                  hintText: 'e.g. Electronics',
                  prefixIcon: Icon(Icons.category_rounded),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Enter a category name'
                    : null,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
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
                  const SizedBox(width: 12),
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
                        labelText: 'Code',
                        hintText: 'e.g. ELEC',
                        prefixIcon: Icon(Icons.tag_rounded),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _SectionLabel('Under'),
              const SizedBox(height: 8),
              Autocomplete<StockCategory>(
                initialValue: TextEditingValue(
                  text: _parent?.name ?? 'Primary',
                ),
                displayStringForOption: (category) => category.name,
                optionsBuilder: (TextEditingValue value) {
                  final query = value.text.trim().toLowerCase();
                  if (query.isEmpty) return options;
                  return options
                      .where(
                        (category) =>
                            category.name.toLowerCase().contains(query) ||
                            (category.code?.toLowerCase().contains(query) ??
                                false),
                      )
                      .toList();
                },
                onSelected: (category) => setState(() => _parent = category),
                fieldViewBuilder: (context, controller, focusNode, _) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Under',
                      hintText: 'Search and select a parent category',
                      prefixIcon: Icon(Icons.account_tree_outlined),
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
                        constraints: const BoxConstraints(maxWidth: 340),
                        child: ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          children: [
                            for (final category in options)
                              ListTile(
                                dense: true,
                                leading: Icon(
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
              ),
              const SizedBox(height: 20),
              const _SectionLabel('Notes'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
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
