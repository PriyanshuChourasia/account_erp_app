import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/stock_group.dart';
import '../viewModel/stock_group_view_model.dart';

/// Dialog form for creating a new stock group.
///
/// Pops a record with the entered fields on save.
class StockGroupAddDialog extends StatefulWidget {
  const StockGroupAddDialog({super.key});

  @override
  State<StockGroupAddDialog> createState() => _StockGroupAddDialogState();
}

class _StockGroupAddDialogState extends State<StockGroupAddDialog> {
  /// Built-in root option shown first in the Under list. Selecting it means
  /// the group has no parent, so it is sent as a null `parentId`.
  static const _primary = StockGroup(id: '', name: 'Primary');

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _aliasController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _parentController = TextEditingController();
  final _parentFocusNode = FocusNode();
  StockGroup _parent = _primary;
  bool _shouldAddQuantities = true;
  bool _setAlterGstDetails = false;

  @override
  void initState() {
    super.initState();
    _parentController.text = _primary.name;
    _parentFocusNode.addListener(_onParentFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final viewModel = context.read<StockGroupViewModel>();
      if (viewModel.stockGroups.isEmpty) viewModel.loadStockGroups();
    });
  }

  void _selectParent(StockGroup group) {
    setState(() => _parent = group);
    _parentController.text = group.name;
  }

  /// When the Under box loses focus, show the selected group's name again so
  /// half-typed search text never looks like a selection. A cleared box
  /// falls back to [_primary].
  void _onParentFocusChange() {
    if (_parentFocusNode.hasFocus) return;
    _selectParent(_parentController.text.trim().isEmpty ? _primary : _parent);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aliasController.dispose();
    _descriptionController.dispose();
    _parentFocusNode.removeListener(_onParentFocusChange);
    _parentFocusNode.dispose();
    _parentController.dispose();
    super.dispose();
  }

  /// [_primary] followed by the loaded groups, filtered to those whose name or
  /// code contains [text]. Shows every option while the box is empty or still
  /// holds the selected group's name. A backend group named "Primary" is
  /// hidden so it never duplicates the built-in option.
  List<StockGroup> _filterGroups(List<StockGroup> groups, String text) {
    final all = [
      _primary,
      ...groups.where((group) => group.name.toLowerCase() != 'primary'),
    ];
    final query = text.trim().toLowerCase();
    if (query.isEmpty || text == _parent.name) return all;
    return all
        .where(
          (group) =>
              group.name.toLowerCase().contains(query) ||
              (group.code?.toLowerCase().contains(query) ?? false),
        )
        .toList();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop((
      name: _nameController.text.trim(),
      alias: _aliasController.text.trim().isEmpty
          ? null
          : _aliasController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      parentId: identical(_parent, _primary) ? null : _parent.id,
      shouldAddQuantities: _shouldAddQuantities,
      setAlterGstDetails: _setAlterGstDetails,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<StockGroupViewModel>().stockGroups;

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
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      content: SizedBox(
        width: 640,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SectionLabel('Under'),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) =>
                      RawAutocomplete<StockGroup>(
                        textEditingController: _parentController,
                        focusNode: _parentFocusNode,
                        displayStringForOption: (group) => group.name,
                        optionsBuilder: (value) =>
                            _filterGroups(groups, value.text),
                        onSelected: _selectParent,
                        fieldViewBuilder: (context, controller, focusNode, _) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Under',
                              hintText: 'Search and select a parent group',
                              suffixIcon: const Icon(
                                Icons.arrow_drop_down_rounded,
                              ),
                            ),
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return _ParentGroupOptions(
                            width: constraints.maxWidth,
                            groups: options.toList(),
                            selected: _parent,
                            onSelected: onSelected,
                          );
                        },
                      ),
                ),
                const SizedBox(height: 20),
                const _SectionLabel('Details'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g. Trading Goods',
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter a group name'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _aliasController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Alias (optional)',
                  ),
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
                  subtitle: const Text(
                    'Enable quantity tracking for this group',
                  ),
                ),
                SwitchListTile(
                  value: _setAlterGstDetails,
                  onChanged: (value) =>
                      setState(() => _setAlterGstDetails = value),
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

/// Drop-down list shown under the Under box while it is focused; the
/// [selected] group is highlighted with a check mark.
class _ParentGroupOptions extends StatelessWidget {
  const _ParentGroupOptions({
    required this.width,
    required this.groups,
    required this.selected,
    required this.onSelected,
  });

  final double width;
  final List<StockGroup> groups;
  final StockGroup? selected;
  final ValueChanged<StockGroup> onSelected;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width, maxHeight: 240),
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              final isSelected = group.id == selected?.id;
              return ListTile(
                dense: true,
                selected: isSelected,
                selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
                title: Text(group.name),
                subtitle: group.code != null ? Text(group.code!) : null,
                trailing: isSelected
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                onTap: () => onSelected(group),
              );
            },
          ),
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
