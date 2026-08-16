import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../../account_nature/models/account_nature.dart';
import '../../account_nature/viewModel/account_nature_view_model.dart';
import '../models/account_group.dart';
import '../models/create_account_group_request.dart';
import '../models/update_account_group_request.dart';
import '../viewModel/account_group_view_model.dart';

/// A selectable "Under" (parent) option.
///
/// [id] is `null` for the root "Primary" placeholder, which maps to a
/// `null` `parentId` on the request.
class _ParentOption {
  const _ParentOption(this.name, this.id);

  final String name;
  final int? id;
}

/// Full-page form for creating or editing an accounting group.
///
/// Fills the maximum available width and height. When [initialGroup] is
/// provided the form is in edit mode, otherwise it creates a new group.
/// Pops a [CreateAccountGroupRequest] (create) or an
/// [UpdateAccountGroupRequest] (edit) on save.
class AccountGroupCreateForm extends StatefulWidget {
  const AccountGroupCreateForm({super.key, this.initialGroup});

  final AccountGroup? initialGroup;

  @override
  State<AccountGroupCreateForm> createState() => _AccountGroupCreateFormState();
}

class _AccountGroupCreateFormState extends State<AccountGroupCreateForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.initialGroup?.name ?? '',
  );
  late final _codeController = TextEditingController(
    text: widget.initialGroup?.code?.toString() ?? '',
  );
  late final _aliasController = TextEditingController(
    text: widget.initialGroup?.alias ?? '',
  );
  late final _descriptionController = TextEditingController(
    text: widget.initialGroup?.description ?? '',
  );

  static const _primaryOption = _ParentOption('Primary', null);
  late _ParentOption _parent = _parentOptions.firstWhere(
    (option) => option.id == widget.initialGroup?.parentId,
    orElse: () => _primaryOption,
  );
  late int? _accountNatureId = widget.initialGroup?.accountNatureId;

  @override
  void initState() {
    super.initState();
    final natureViewModel = context.read<AccountNatureViewModel>();
    if (natureViewModel.accountNatures.isEmpty && !natureViewModel.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) natureViewModel.loadAccountNatures();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _aliasController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<_ParentOption> get _parentOptions {
    final groups = context.read<AccountGroupViewModel>().accountingGroups;
    final source = groups.isEmpty ? AccountGroup.demo : groups;
    return [
      _primaryOption,
      for (final group in source) _ParentOption(group.name, group.id),
    ];
  }

  List<AccountNature> get _natureOptions {
    final natures = context.read<AccountNatureViewModel>().accountNatures;
    return natures.isEmpty ? AccountNature.demo : natures;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final name = _nameController.text.trim();
    final code = int.parse(_codeController.text.trim());
    final alias = _aliasController.text.trim().isEmpty
        ? null
        : _aliasController.text.trim();
    final description = _descriptionController.text.trim().isEmpty
        ? null
        : _descriptionController.text.trim();

    final initialGroup = widget.initialGroup;
    if (initialGroup != null) {
      Navigator.of(context).pop(
        UpdateAccountGroupRequest(
          id: initialGroup.id,
          name: name,
          code: code,
          alias: alias,
          description: description,
          parentId: _parent.id,
          accountNatureId: _accountNatureId!,
        ),
      );
    } else {
      Navigator.of(context).pop(
        CreateAccountGroupRequest(
          name: name,
          code: code,
          alias: alias,
          description: description,
          parentId: _parent.id,
          accountNatureId: _accountNatureId!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialGroup != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit accounting group' : 'Add accounting group',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _SectionLabel('Details'),
                    const SizedBox(height: 16),
                    const _FieldLabel('Name'),
                    TextFormField(
                      controller: _nameController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Sundry Debtors',
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Enter a group name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    const _FieldLabel('Code'),
                    TextFormField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'e.g. 101'),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) return 'Enter a group code';
                        if (int.tryParse(text) == null) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const _FieldLabel('Alias (optional)'),
                    TextFormField(
                      controller: _aliasController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Receivables',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _FieldLabel('Description (optional)'),
                    TextFormField(
                      controller: _descriptionController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Short description of the group',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _SectionLabel('Under'),
                    const SizedBox(height: 16),
                    Autocomplete<_ParentOption>(
                      initialValue: TextEditingValue(text: _parent.name),
                      displayStringForOption: (option) => option.name,
                      optionsBuilder: (TextEditingValue value) {
                        final query = value.text.trim().toLowerCase();
                        if (query.isEmpty) return _parentOptions;
                        return _parentOptions
                            .where(
                              (option) =>
                                  option.name.toLowerCase().contains(query),
                            )
                            .toList();
                      },
                      onSelected: (option) => setState(() => _parent = option),
                      fieldViewBuilder: (context, controller, focusNode, _) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            hintText: 'Search and select a parent group',
                            suffixIcon: Icon(Icons.arrow_drop_down_rounded),
                          ),
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(12),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 480),
                              child: ListView(
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                children: [
                                  for (final option in options)
                                    ListTile(
                                      dense: true,
                                      leading: Icon(
                                        option.id == null
                                            ? Icons.home_rounded
                                            : Icons.account_tree_rounded,
                                        size: 20,
                                        color: AppColors.textSecondary,
                                      ),
                                      title: Text(option.name),
                                      onTap: () => onSelected(option),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const _SectionLabel('Account Nature'),
                    const SizedBox(height: 16),
                    FormField<int>(
                      initialValue: _accountNatureId,
                      validator: (value) =>
                          value == null ? 'Select an account nature' : null,
                      builder: (field) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final nature in _natureOptions)
                                ChoiceChip(
                                  label: Text(nature.name),
                                  selected: _accountNatureId == nature.id,
                                  onSelected: (selected) {
                                    setState(
                                      () => _accountNatureId = selected
                                          ? nature.id
                                          : null,
                                    );
                                    field.didChange(_accountNatureId);
                                  },
                                ),
                            ],
                          ),
                          if (field.hasError) ...[
                            const SizedBox(height: 8),
                            Text(
                              field.errorText!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: Text(isEditing ? 'Update' : 'Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
