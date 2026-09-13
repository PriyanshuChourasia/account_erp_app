import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/application_feature.dart';
import '../models/create_application_feature_request.dart';

/// Dialog form for creating a new application feature.
///
/// Pops a [CreateApplicationFeatureRequest] on save.
class ApplicationFeatureAddDialog extends StatefulWidget {
  const ApplicationFeatureAddDialog({super.key});

  @override
  State<ApplicationFeatureAddDialog> createState() =>
      _ApplicationFeatureAddDialogState();
}

class _ApplicationFeatureAddDialogState
    extends State<ApplicationFeatureAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _endPointController = TextEditingController();
  final _descriptionController = TextEditingController();
  ApiMethod _apiMethod = ApiMethod.get;
  ApiDeviceType _apiDeviceType = ApiDeviceType.all;
  bool _active = true;

  @override
  void dispose() {
    _nameController.dispose();
    _endPointController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      CreateApplicationFeatureRequest(
        name: _nameController.text.trim(),
        apiMethod: _apiMethod,
        apiDeviceType: _apiDeviceType,
        endPoint: _endPointController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        active: _active,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final dialogWidth = screenWidth < 480 ? screenWidth * 0.9 : 440.0;

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
              Icons.extension_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Add application feature'),
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
                    hintText: 'e.g. Account Nature',
                    prefixIcon: Icon(Icons.extension_rounded),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter a feature name'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _endPointController,
                  decoration: const InputDecoration(
                    labelText: 'Endpoint',
                    hintText: 'e.g. account_natures',
                    prefixIcon: Icon(Icons.link_rounded),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter an endpoint'
                      : null,
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<ApiMethod>(
                        initialValue: _apiMethod,
                        decoration: const InputDecoration(
                          labelText: 'API method',
                          prefixIcon: Icon(Icons.http_rounded),
                        ),
                        items: [
                          for (final method in ApiMethod.values)
                            DropdownMenuItem(
                              value: method,
                              child: Text(method.name.toUpperCase()),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _apiMethod = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<ApiDeviceType>(
                        initialValue: _apiDeviceType,
                        decoration: const InputDecoration(
                          labelText: 'Device type',
                          prefixIcon: Icon(Icons.devices_rounded),
                        ),
                        items: [
                          for (final deviceType in ApiDeviceType.values)
                            DropdownMenuItem(
                              value: deviceType,
                              child: Text(deviceType.name.toUpperCase()),
                            ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _apiDeviceType = value);
                          }
                        },
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
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  subtitle: const Text('Reachable and usable across the app'),
                  value: _active,
                  onChanged: (value) => setState(() => _active = value),
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
