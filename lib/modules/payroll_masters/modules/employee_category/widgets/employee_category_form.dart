import 'package:flutter/material.dart';

import '../../../../../../config/theme/app_theme.dart';
import '../models/create_employee_category_request.dart';
import '../models/employee_category.dart';

/// Inline form for creating an employee category, or editing [editing] when
/// one is selected.
///
/// Calls [onSubmit] with the built request; the form clears itself when it
/// returns true.
class EmployeeCategoryForm extends StatefulWidget {
  const EmployeeCategoryForm({
    super.key,
    required this.onSubmit,
    this.editing,
    this.onCancelEdit,
  });

  final EmployeeCategory? editing;
  final Future<bool> Function(CreateEmployeeCategoryRequest request) onSubmit;
  final VoidCallback? onCancelEdit;

  @override
  State<EmployeeCategoryForm> createState() => _EmployeeCategoryFormState();
}

class _EmployeeCategoryFormState extends State<EmployeeCategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _aliasController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _allocateRevenueItem = false;
  bool _allocateNonRevenueItem = false;
  bool _isSaving = false;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    _fill(widget.editing);
  }

  @override
  void didUpdateWidget(EmployeeCategoryForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.editing?.id != widget.editing?.id) _fill(widget.editing);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aliasController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _fill(EmployeeCategory? category) {
    // Reset first to clear validation errors: reset() restores the fields'
    // old values, so the new ones must be set after it.
    _formKey.currentState?.reset();
    _nameController.text = category?.name ?? '';
    _aliasController.text = category?.alias ?? '';
    _descriptionController.text = category?.description ?? '';
    _allocateRevenueItem = category?.allocateRevenueItem ?? false;
    _allocateNonRevenueItem = category?.allocateNonRevenueItem ?? false;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);
    final saved = await widget.onSubmit(
      CreateEmployeeCategoryRequest(
        name: _nameController.text.trim(),
        alias: _aliasController.text.trim().isEmpty
            ? null
            : _aliasController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        allocateRevenueItem: _allocateRevenueItem,
        allocateNonRevenueItem: _allocateNonRevenueItem,
      ),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (saved) setState(() => _fill(null));
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
                  _isEditing ? Icons.edit_rounded : Icons.category_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isEditing
                      ? 'Edit employee category'
                      : 'Add employee category',
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
              hintText: 'e.g. Teaching',
              prefixIcon: Icon(Icons.category_rounded),
            ),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Enter category name'
                : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _aliasController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Alias (optional)',
              hintText: 'e.g. Faculty',
              prefixIcon: Icon(Icons.short_text_rounded),
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
              hintText: 'e.g. Teaching staff',
              prefixIcon: Icon(Icons.description_rounded),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          const _SectionLabel('Allocation'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Allocate revenue items'),
            value: _allocateRevenueItem,
            onChanged: _isSaving
                ? null
                : (value) => setState(() => _allocateRevenueItem = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Allocate non-revenue items'),
            value: _allocateNonRevenueItem,
            onChanged: _isSaving
                ? null
                : (value) => setState(() => _allocateNonRevenueItem = value),
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
                    : () => setState(() => _fill(null)),
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
