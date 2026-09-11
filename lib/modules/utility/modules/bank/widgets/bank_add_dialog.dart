import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../../bank_type/models/bank_type.dart';
import '../../bank_type/viewModel/bank_type_view_model.dart';
import '../models/create_bank_request.dart';

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

/// Dialog form for creating a new bank.
///
/// Pops a [CreateBankRequest] on save.
class BankAddDialog extends StatefulWidget {
  const BankAddDialog({super.key});

  @override
  State<BankAddDialog> createState() => _BankAddDialogState();
}

class _BankAddDialogState extends State<BankAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  int? _bankTypeId;

  @override
  void initState() {
    super.initState();
    final bankTypeViewModel = context.read<BankTypeViewModel>();
    if (bankTypeViewModel.bankTypes.isEmpty && !bankTypeViewModel.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) bankTypeViewModel.loadBankTypes();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      CreateBankRequest(
        name: _nameController.text.trim(),
        code: _codeController.text.trim().isEmpty
            ? null
            : _codeController.text.trim().toUpperCase(),
        bankTypeId: _bankTypeId,
      ),
    );
  }

  List<BankType> get _bankTypeOptions {
    final bankTypes = context.read<BankTypeViewModel>().bankTypes;
    return bankTypes.isEmpty ? BankType.demo : bankTypes;
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
              Icons.account_balance_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Add bank'),
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
                    hintText: 'e.g. State Bank of India',
                    prefixIcon: Icon(Icons.account_balance_rounded),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter a bank name'
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
                    hintText: 'e.g. SBI',
                    prefixIcon: Icon(Icons.tag_rounded),
                  ),
                ),
                const SizedBox(height: 20),
                const _SectionLabel('Under'),
                const SizedBox(height: 8),
                DropdownButtonFormField<int?>(
                  decoration: const InputDecoration(
                    hintText: 'Select bank type',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: [
                    for (final bankType in _bankTypeOptions)
                      DropdownMenuItem<int?>(
                        value: bankType.id,
                        child: Text(bankType.name),
                      ),
                  ],
                  onChanged: (value) => setState(() => _bankTypeId = value),
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