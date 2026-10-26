import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/create_designation_request.dart';
import '../models/designation.dart';

/// Dialog form for creating a new designation, or editing [initialDesignation]
/// when one is given.
///
/// Pops a [CreateDesignationRequest] on save.
class DesignationAddDialog extends StatefulWidget {
  const DesignationAddDialog({
    super.key,
    this.initialDesignation,
    this.parentOptions = const [],
  });

  final Designation? initialDesignation;

  /// Designations selectable as the parent (already excludes the one being
  /// edited and its descendants).
  final List<Designation> parentOptions;

  @override
  State<DesignationAddDialog> createState() => _DesignationAddDialogState();
}

class _DesignationAddDialogState extends State<DesignationAddDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.initialDesignation?.name,
  );
  late final _codeController = TextEditingController(
    text: widget.initialDesignation?.code,
  );
  late final _descriptionController = TextEditingController(
    text: widget.initialDesignation?.description,
  );

  bool get _isEditing => widget.initialDesignation != null;

  /// Starts at the current parent so saving an edit never clears it. Falls
  /// back to none if that parent is no longer in the list.
  late String? _parentId =
      widget.parentOptions.any(
        (option) => option.id == widget.initialDesignation?.parentId,
      )
      ? widget.initialDesignation?.parentId
      : null;

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
      CreateDesignationRequest(
        name: _nameController.text.trim(),
        code: _codeController.text.trim().isEmpty
            ? null
            : _codeController.text.trim().toUpperCase(),
        parentId: _parentId,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      ),
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
              Icons.work_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(_isEditing ? 'Edit designation' : 'Add designation'),
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
                    hintText: 'e.g. Senior Accountant',
                    prefixIcon: Icon(Icons.work_rounded),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter a designation name'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Code (optional)',
                    hintText: 'e.g. SR_ACC',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  initialValue: _parentId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Reports to (parent)',
                    prefixIcon: Icon(Icons.account_tree_outlined),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('None (top level)'),
                    ),
                    for (final option in widget.parentOptions)
                      DropdownMenuItem<String?>(
                        value: option.id,
                        child: Text(
                          option.code == null
                              ? option.name
                              : '${option.name} (${option.code})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(() => _parentId = value),
                ),
                const SizedBox(height: 16),
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
          label: Text(_isEditing ? 'Update' : 'Save'),
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
