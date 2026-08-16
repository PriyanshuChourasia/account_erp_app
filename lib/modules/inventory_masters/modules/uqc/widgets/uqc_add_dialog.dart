import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/create_uqc_request.dart';
import '../models/update_uqc_request.dart';
import '../models/uqc.dart';

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

/// Dialog form for creating or editing a UQC.
///
/// When [initialUqc] is provided the dialog is in edit mode, otherwise it
/// creates a new UQC. Pops a [CreateUqcRequest] or an [UpdateUqcRequest] on
/// save.
class UqcFormDialog extends StatefulWidget {
  const UqcFormDialog({super.key, this.initialUqc});

  final Uqc? initialUqc;

  @override
  State<UqcFormDialog> createState() => _UqcFormDialogState();
}

class _UqcFormDialogState extends State<UqcFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController =
      TextEditingController(text: widget.initialUqc?.name ?? '');
  late final _aliasController =
      TextEditingController(text: widget.initialUqc?.alias ?? '');
  late final _codeController =
      TextEditingController(text: widget.initialUqc?.code ?? '');
  late final _descriptionController =
      TextEditingController(text: widget.initialUqc?.description ?? '');

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
    final name = _nameController.text.trim();
    final code = _codeController.text.trim().toUpperCase();
    final alias = _aliasController.text.trim().isEmpty
        ? null
        : _aliasController.text.trim();
    final description = _descriptionController.text.trim().isEmpty
        ? null
        : _descriptionController.text.trim();

    final initialUqc = widget.initialUqc;
    if (initialUqc != null) {
      Navigator.of(context).pop(UpdateUqcRequest(
        id: initialUqc.id,
        name: name,
        code: code,
        alias: alias,
        description: description,
      ));
    } else {
      Navigator.of(context).pop(CreateUqcRequest(
        name: name,
        code: code,
        alias: alias,
        description: description,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final dialogWidth = screenWidth < 480 ? screenWidth * 0.9 : 420.0;
    final isEditing = widget.initialUqc != null;

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
              Icons.straighten_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(isEditing ? 'Edit UQC' : 'Add UQC'),
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
                    hintText: 'e.g. Numbers',
                    prefixIcon: Icon(Icons.straighten_rounded),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter a UQC name'
                      : null,
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        maxLength: 3,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Za-z0-9]'),
                          ),
                          _UpperCaseTextFormatter(),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Code',
                          hintText: 'e.g. NOS',
                          prefixIcon: Icon(Icons.tag_rounded),
                          counterText: '',
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Enter a code'
                            : null,
                      ),
                    ),
                  ],
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
          label: Text(isEditing ? 'Update' : 'Save'),
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
