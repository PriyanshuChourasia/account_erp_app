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

/// A selectable "Under" (parent) option.
///
/// [id] is `null` for the root "Primary" placeholder, which maps to a
/// `null` `parentId` on the request.
class _ParentOption {
  const _ParentOption(this.name, this.id);

  final String name;
  final int? id;
}

/// Full-page form for creating a new stock category.
///
/// Fills the maximum available width and height and adapts its field layout
/// to the screen size. Pops a [CreateStockCategoryRequest] on save. The
/// "Under" parent defaults to Primary — the root — so it submits `null` as
/// the parentId.
class StockCategoryCreateForm extends StatefulWidget {
  const StockCategoryCreateForm({super.key});

  @override
  State<StockCategoryCreateForm> createState() =>
      _StockCategoryCreateFormState();
}

class _StockCategoryCreateFormState extends State<StockCategoryCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _aliasController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();

  static const _primaryOption = _ParentOption('Primary', null);
  _ParentOption _parent = _primaryOption;

  @override
  void dispose() {
    _nameController.dispose();
    _aliasController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<_ParentOption> get _parentOptions {
    final categories = context.read<StockCategoryViewModel>().stockCategories;
    final source = categories.isEmpty ? StockCategory.demo : categories;
    return [
      _primaryOption,
      for (final category in source) _ParentOption(category.name, category.id),
    ];
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(CreateStockCategoryRequest(
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
      parentId: _parent.id,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add stock category')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 720;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
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
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Enter a category name'
                                  : null,
                        ),
                        const SizedBox(height: 14),
                        if (wide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _aliasController,
                                  textCapitalization:
                                      TextCapitalization.words,
                                  decoration: const InputDecoration(
                                    labelText: 'Alias (optional)',
                                    prefixIcon: Icon(
                                      Icons.alternate_email_rounded,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _codeController,
                                  textCapitalization:
                                      TextCapitalization.characters,
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
                          )
                        else ...[
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
                        ],
                        const SizedBox(height: 20),
                        const _SectionLabel('Under'),
                        const SizedBox(height: 8),
                        Autocomplete<_ParentOption>(
                          initialValue:
                              TextEditingValue(text: _parent.name),
                          displayStringForOption: (option) => option.name,
                          optionsBuilder: (TextEditingValue value) {
                            final query = value.text.trim().toLowerCase();
                            if (query.isEmpty) return _parentOptions;
                            return _parentOptions
                                .where((option) =>
                                    option.name.toLowerCase().contains(query))
                                .toList();
                          },
                          onSelected: (option) =>
                              setState(() => _parent = option),
                          fieldViewBuilder: (context, controller, focusNode, _) {
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: 'Under',
                                hintText: 'Search and select a parent category',
                                prefixIcon:
                                    Icon(Icons.account_tree_outlined),
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
                                  constraints:
                                      const BoxConstraints(maxWidth: 480),
                                  child: ListView(
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4),
                                    children: [
                                      for (final option in options)
                                        ListTile(
                                          dense: true,
                                          leading: Icon(
                                            option.id == null
                                                ? Icons.home_rounded
                                                : Icons.category_rounded,
                                            size: 20,
                                            color: AppColors.textSecondary,
                                          ),
                                          title: Text(option.name),
                                          onTap: () => onSelected(option),
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
                          maxLines: wide ? 4 : 3,
                          decoration: const InputDecoration(
                            labelText: 'Description (optional)',
                            alignLabelWithHint: true,
                            prefixIcon: Icon(Icons.notes_rounded),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: _submit,
                              icon: const Icon(Icons.check_rounded, size: 18),
                              label: const Text('Save'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
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
