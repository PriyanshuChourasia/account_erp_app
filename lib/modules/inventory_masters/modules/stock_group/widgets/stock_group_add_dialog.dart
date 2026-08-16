import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/stock_group.dart';
import '../viewModel/stock_group_view_model.dart';

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

/// Dialog form for creating a new stock group.
///
/// Pops a record with the entered fields on save.
class StockGroupAddDialog extends StatefulWidget {
  const StockGroupAddDialog({super.key});

  @override
  State<StockGroupAddDialog> createState() => _StockGroupAddDialogState();
}

class _StockGroupAddDialogState extends State<StockGroupAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _aliasController = TextEditingController();
  final _descriptionController = TextEditingController();
  StockGroup? _parent;
  bool _shouldAddQuantities = true;
  bool _setAlterGstDetail = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final groups = context.read<StockGroupViewModel>().stockGroups;
      if (groups.isEmpty) return;
      setState(() {
        _parent = groups.where((group) => group.name == 'Primary').firstOrNull;
        _parent ??= groups.first;
      });
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
      parentId: _parent?.id,
      shouldAddQuantities: _shouldAddQuantities,
      setAlterGstDetail: _setAlterGstDetail,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<StockGroupViewModel>().stockGroups;
    final options = groups.isEmpty ? StockGroup.demo : groups;

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
              Icons.folder_special_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Add stock group'),
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
                  hintText: 'e.g. Trading Goods',
                  prefixIcon: Icon(Icons.folder_rounded),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Enter a group name'
                    : null,
              ),
              const SizedBox(height: 14),
              Row(
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
                        labelText: 'Code',
                        hintText: 'e.g. TRAD',
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
              const _SectionLabel('Under'),
              const SizedBox(height: 8),
              Autocomplete<StockGroup>(
                initialValue: TextEditingValue(
                  text: _parent?.name ?? 'Primary',
                ),
                displayStringForOption: (group) => group.name,
                optionsBuilder: (TextEditingValue value) {
                  final query = value.text.trim().toLowerCase();
                  if (query.isEmpty) return options;
                  return options
                      .where(
                        (group) =>
                            group.name.toLowerCase().contains(query) ||
                            (group.code?.toLowerCase().contains(query) ??
                                false),
                      )
                      .toList();
                },
                onSelected: (group) => setState(() => _parent = group),
                fieldViewBuilder: (context, controller, focusNode, _) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Under',
                      hintText: 'Search and select a parent group',
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
                            for (final group in options)
                              ListTile(
                                dense: true,
                                leading: Icon(
                                  Icons.folder_rounded,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                                title: Text(group.name),
                                subtitle: group.code != null
                                    ? Text(group.code!)
                                    : null,
                                onTap: () => onSelected(group),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const _SectionLabel('Options'),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _shouldAddQuantities,
                onChanged: (value) =>
                    setState(() => _shouldAddQuantities = value),
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.numbers_rounded),
                title: const Text('Maintain quantities'),
                subtitle: const Text('Enable quantity tracking for this group'),
              ),
              SwitchListTile(
                value: _setAlterGstDetail,
                onChanged: (value) =>
                    setState(() => _setAlterGstDetail = value),
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.settings_rounded),
                title: const Text('Set/alter GST details'),
                subtitle: const Text('Allow GST configuration on this group'),
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
