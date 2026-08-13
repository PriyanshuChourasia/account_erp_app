import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/create_financial_year_request.dart';
import '../utils/date_helpers.dart';

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

/// Dialog form for creating a new financial year.
///
/// Mirrors the backend `CreateFinancialYearDTO` (dates are sent as
/// `dd-MM-yyyy`). Pops a [CreateFinancialYearRequest] on save.
class FinancialYearAddDialog extends StatefulWidget {
  const FinancialYearAddDialog({super.key});

  @override
  State<FinancialYearAddDialog> createState() => _FinancialYearAddDialogState();
}

class _FinancialYearAddDialogState extends State<FinancialYearAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrent = false;
  String? _dateError;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime(now.year, 4, 1),
      firstDate: DateTime(now.year - 10, 4, 1),
      lastDate: _endDate ?? DateTime(now.year + 10, 12, 31),
    );
    if (picked == null) return;
    setState(() {
      _startDate = picked;
      // Filling a typical Apr–Mar period makes the common case one-tap.
      _endDate ??= _suggestEndDate(picked);
      _suggestNameAndCode(picked);
      _dateError = null;
    });
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime(now.year, 3, 31),
      firstDate: _startDate ?? DateTime(now.year - 10, 4, 1),
      lastDate: DateTime(now.year + 10, 12, 31),
    );
    if (picked == null) return;
    setState(() {
      _endDate = picked;
      _startDate ??= _suggestStartDate(picked);
      _suggestNameAndCode(picked);
      _dateError = null;
    });
  }

  /// Typical end of an Apr–Mar fiscal year that contains [start].
  DateTime _suggestEndDate(DateTime start) =>
      DateTime(start.month > 3 ? start.year + 1 : start.year, 3, 31);

  /// Typical start of the Apr–Mar fiscal year that contains [end].
  DateTime _suggestStartDate(DateTime end) =>
      DateTime(end.month <= 3 ? end.year - 1 : end.year, 4, 1);

  /// Pre-fills the name/code (only when still empty) from the fiscal year
  /// containing [date], following the `FY 2024-25` / `FY2425` convention.
  void _suggestNameAndCode(DateTime date) {
    final startYear = date.month > 3 ? date.year : date.year - 1;
    final endYear = startYear + 1;
    if (_nameController.text.trim().isEmpty) {
      _nameController.text = 'FY $startYear-${endYear % 100}';
    }
    if (_codeController.text.trim().isEmpty) {
      _codeController.text = 'FY${startYear % 100}${endYear % 100}';
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final start = _startDate;
    final end = _endDate;
    if (start == null || end == null) {
      setState(() => _dateError = 'Start and end dates are required.');
      return;
    }
    if (end.isBefore(start)) {
      setState(() => _dateError = 'End date must be after the start date.');
      return;
    }
    Navigator.of(context).pop(CreateFinancialYearRequest(
      name: _nameController.text.trim(),
      code: _codeController.text.trim().isEmpty
          ? null
          : _codeController.text.trim().toUpperCase(),
      startDate: start,
      endDate: end,
      isCurrent: _isCurrent,
    ));
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
              Icons.calendar_month_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Add financial year'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionLabel('Period'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _DatePickerField(
                      label: 'Start date',
                      date: _startDate,
                      icon: Icons.today_rounded,
                      onTap: _pickStartDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DatePickerField(
                      label: 'End date',
                      date: _endDate,
                      icon: Icons.event_rounded,
                      onTap: _pickEndDate,
                    ),
                  ),
                ],
              ),
              if (_dateError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _dateError!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ],
              const SizedBox(height: 16),
              const _SectionLabel('Details'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g. FY 2024-25',
                  prefixIcon: Icon(Icons.event_note_rounded),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Enter a financial year name'
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
                  hintText: 'e.g. FY2425',
                  prefixIcon: Icon(Icons.tag_rounded),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isCurrent,
                onChanged: (value) => setState(() => _isCurrent = value),
                title: const Text('Set as current year'),
                subtitle: const Text(
                  'Mark this as the fiscal year used for transactions.',
                ),
                secondary: const Icon(
                  Icons.star_outline_rounded,
                  color: AppColors.primary,
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

/// Tappable field that opens a date picker and shows the chosen date.
class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.date,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          suffixIcon: const Icon(Icons.calendar_today_rounded, size: 16),
        ),
        child: Text(
          date == null ? 'Select' : formatFinancialDate(date!),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: date == null
                ? AppColors.textSecondary
                : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
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
