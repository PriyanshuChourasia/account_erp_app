import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../../account_group/viewModel/account_group_view_model.dart';
import '../models/create_account_ledger_request.dart';

/// Dialog form for creating a new account ledger.
///
/// Pops a [CreateAccountLedgerRequest] on save.
class AccountLedgerAddDialog extends StatefulWidget {
  const AccountLedgerAddDialog({super.key});

  @override
  State<AccountLedgerAddDialog> createState() => _AccountLedgerAddDialogState();
}

class _AccountLedgerAddDialogState extends State<AccountLedgerAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _aliasController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _groupId;

  @override
  void dispose() {
    _nameController.dispose();
    _aliasController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      CreateAccountLedgerRequest(
        name: _nameController.text.trim(),
        alias: _aliasController.text.trim().isEmpty
            ? null
            : _aliasController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        groupId: _groupId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final dialogWidth = screenWidth < 480 ? screenWidth * 0.9 : 440.0;
    final groups =
        context.read<AccountGroupViewModel>().accountingGroups;

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
              Icons.menu_book_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Add account ledger'),
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
                    hintText: 'e.g. Cash in Hand',
                    prefixIcon: Icon(Icons.menu_book_rounded),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter a ledger name'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _aliasController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Alias (optional)',
                    hintText: 'e.g. Cash',
                    prefixIcon: Icon(Icons.alternate_email_rounded),
                  ),
                ),
                const SizedBox(height: 20),
                const _SectionLabel('Under'),
                const SizedBox(height: 8),
                DropdownButtonFormField<int?>(
                  decoration: const InputDecoration(
                    hintText: 'Select account group',
                    prefixIcon: Icon(Icons.account_tree_rounded),
                  ),
                  items: [
                    for (final group in groups)
                      DropdownMenuItem<int?>(
                        value: group.id,
                        child: Text(group.name),
                      ),
                  ],
                  onChanged: (value) => setState(() => _groupId = value),
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