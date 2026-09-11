import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../../bank/models/bank.dart';
import '../../bank/viewModel/bank_view_model.dart';
import '../models/create_bank_branch_request.dart';

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

/// Dialog form for creating a new bank branch.
///
/// Pops a [CreateBankBranchRequest] on save.
class BankBranchAddDialog extends StatefulWidget {
  const BankBranchAddDialog({super.key});

  @override
  State<BankBranchAddDialog> createState() => _BankBranchAddDialogState();
}

class _BankBranchAddDialogState extends State<BankBranchAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ifscController = TextEditingController();
  final _addressController = TextEditingController();

  int? _bankId;

  @override
  void initState() {
    super.initState();
    final bankViewModel = context.read<BankViewModel>();
    if (bankViewModel.banks.isEmpty && !bankViewModel.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) bankViewModel.loadBanks();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ifscController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      CreateBankBranchRequest(
        name: _nameController.text.trim(),
        bankId: _bankId,
        ifscCode: _ifscController.text.trim().isEmpty
            ? null
            : _ifscController.text.trim().toUpperCase(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
      ),
    );
  }

  List<Bank> get _bankOptions {
    final banks = context.read<BankViewModel>().banks;
    return banks.isEmpty ? Bank.demo : banks;
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
              Icons.store_mall_directory_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Add bank branch'),
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
                    hintText: 'e.g. SBI - Andheri West',
                    prefixIcon: Icon(Icons.store_mall_directory_rounded),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter a branch name'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _ifscController,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                    _UpperCaseTextFormatter(),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'IFSC code (optional)',
                    hintText: 'e.g. SBIN0001234',
                    prefixIcon: Icon(Icons.pin_rounded),
                  ),
                ),
                const SizedBox(height: 20),
                const _SectionLabel('Under'),
                const SizedBox(height: 8),
                DropdownButtonFormField<int?>(
                  decoration: const InputDecoration(
                    hintText: 'Select bank',
                    prefixIcon: Icon(Icons.account_balance_rounded),
                  ),
                  items: [
                    for (final bank in _bankOptions)
                      DropdownMenuItem<int?>(
                        value: bank.id,
                        child: Text(bank.name),
                      ),
                  ],
                  onChanged: (value) => setState(() => _bankId = value),
                ),
                const SizedBox(height: 20),
                const _SectionLabel('Notes'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Address (optional)',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.location_on_outlined),
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