import 'package:flutter/material.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/create_address_request.dart';
import '../widgets/address_form_section.dart';

/// Dialog form for creating a new address.
///
/// Pops a [CreateAddressRequest] on save. The field layout is shared with the
/// company create dialog via [AddressFormSection].
class AddressAddDialog extends StatefulWidget {
  const AddressAddDialog({super.key});

  @override
  State<AddressAddDialog> createState() => _AddressAddDialogState();
}

class _AddressAddDialogState extends State<AddressAddDialog> {
  final _sectionKey = GlobalKey<AddressFormSectionState>();

  void _submit() {
    final request = _sectionKey.currentState?.validateAndBuild();
    if (request == null) return;
    Navigator.of(context).pop(request);
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
              Icons.location_on_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Add address'),
        ],
      ),
      content: SingleChildScrollView(
        child: AddressFormSection(key: _sectionKey),
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
