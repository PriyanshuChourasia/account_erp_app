import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/create_application_module_request.dart';

/// Dialog form for creating a new application module.
///
/// Pops a [CreateApplicationModuleRequest] on save.
class ApplicationModuleAddDialog extends StatefulWidget {
  const ApplicationModuleAddDialog({super.key});

  @override
  State<ApplicationModuleAddDialog> createState() =>
      _ApplicationModuleAddDialogState();
}

class _ApplicationModuleAddDialogState
    extends State<ApplicationModuleAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _endpointController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSystem = false;

  @override
  void dispose() {
    _nameController.dispose();
    _endpointController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      CreateApplicationModuleRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        endpoint: _endpointController.text.trim().isEmpty
            ? null
            : _endpointController.text.trim(),
        isSystem: _isSystem,
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
              Icons.widgets_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Add application module'),
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
                    hintText: 'e.g. Accounting Masters',
                    prefixIcon: Icon(Icons.widgets_rounded),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter a module name'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _endpointController,
                  decoration: const InputDecoration(
                    labelText: 'Endpoint (optional)',
                    hintText: 'e.g. accounting-masters',
                    prefixIcon: Icon(Icons.link_rounded),
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
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('System module'),
                  subtitle: const Text(
                    'Built-in module that ships with the application',
                  ),
                  value: _isSystem,
                  onChanged: (value) => setState(() => _isSystem = value),
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
