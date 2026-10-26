import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../config/theme/app_theme.dart';
import '../models/create_employee_group_request.dart';
import '../models/employee_group.dart';

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

/// Inline form for creating an employee group, or editing [editing] when
/// one is selected.
///
/// Calls [onSubmit] with the built request; the form clears itself when it
/// returns true.
class EmployeeGroupForm extends StatefulWidget {
  const EmployeeGroupForm({
    super.key,
    required this.onSubmit,
    this.editing,
    this.onCancelEdit,
  });

  final EmployeeGroup? editing;
  final Future<bool> Function(CreateEmployeeGroupRequest request) onSubmit;
  final VoidCallback? onCancelEdit;

  @override
  State<EmployeeGroupForm> createState() => _EmployeeGroupFormState();
}

class _EmployeeGroupFormState extends State<EmployeeGroupForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSaving = false;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    _fill(widget.editing);
  }

  @override
  void didUpdateWidget(EmployeeGroupForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.editing?.id != widget.editing?.id) _fill(widget.editing);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _fill(EmployeeGroup? group) {
    // Reset first to clear validation errors: reset() restores the fields'
    // old values, so the new ones must be set after it.
    _formKey.currentState?.reset();
    _nameController.text = group?.name ?? '';
    _codeController.text = group?.code ?? '';
    _descriptionController.text = group?.description ?? '';
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);
    final saved = await widget.onSubmit(
      CreateEmployeeGroupRequest(
        name: _nameController.text.trim(),
        code: _codeController.text.trim().isEmpty
            ? null
            : _codeController.text.trim().toUpperCase(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      ),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (saved) _fill(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _isEditing ? Icons.edit_rounded : Icons.groups_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isEditing ? 'Edit employee group' : 'Add employee group',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _SectionLabel('Details'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'e.g. Permanent',
              prefixIcon: Icon(Icons.groups_rounded),
            ),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Enter group name'
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
              hintText: 'e.g. PERM',
              prefixIcon: Icon(Icons.tag_rounded),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _descriptionController,
            textCapitalization: TextCapitalization.sentences,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'e.g. Regular full-time employees',
              prefixIcon: Icon(Icons.description_rounded),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 12,
            runSpacing: 8,
            children: [
              TextButton(
                onPressed: _isSaving
                    ? null
                    : _isEditing
                    ? widget.onCancelEdit
                    : () => _fill(null),
                child: Text(_isEditing ? 'Cancel' : 'Clear'),
              ),
              FilledButton.icon(
                onPressed: _isSaving ? null : _submit,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded, size: 18),
                label: Text(_isEditing ? 'Update' : 'Save'),
              ),
            ],
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
