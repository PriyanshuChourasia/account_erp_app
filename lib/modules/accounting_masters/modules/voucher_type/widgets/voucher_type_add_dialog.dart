import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/create_voucher_type_request.dart';

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

/// Dialog form for creating a new voucher type.
///
/// Pops a [CreateVoucherTypeRequest] on save.
class VoucherTypeAddDialog extends StatefulWidget {
  const VoucherTypeAddDialog({super.key});

  @override
  State<VoucherTypeAddDialog> createState() => _VoucherTypeAddDialogState();
}

class _VoucherTypeAddDialogState extends State<VoucherTypeAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();

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
      CreateVoucherTypeRequest(
        name: _nameController.text.trim(),
        code: _codeController.text.trim().isEmpty
            ? null
            : _codeController.text.trim().toUpperCase(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              Icons.receipt_long_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Add voucher type'),
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
                  hintText: 'e.g. Payment',
                  prefixIcon: Icon(Icons.receipt_long_rounded),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Enter a voucher type name'
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
                  hintText: 'e.g. PAY',
                  prefixIcon: Icon(Icons.tag_rounded),
                ),
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
