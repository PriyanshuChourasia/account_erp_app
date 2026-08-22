import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../config/theme/app_theme.dart';
import '../models/create_country_request.dart';

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

/// Dialog form for creating a new country.
///
/// Pops a [CreateCountryRequest] on save.
class CountryAddDialog extends StatefulWidget {
  const CountryAddDialog({super.key});

  @override
  State<CountryAddDialog> createState() => _CountryAddDialogState();
}

class _CountryAddDialogState extends State<CountryAddDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _aliasController = TextEditingController();
  final _iso2Controller = TextEditingController();
  final _iso3Controller = TextEditingController();
  final _numericController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currencyCodeController = TextEditingController();
  final _currencyNameController = TextEditingController();
  final _regionController = TextEditingController();
  final _subRegionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _aliasController.dispose();
    _iso2Controller.dispose();
    _iso3Controller.dispose();
    _numericController.dispose();
    _phoneController.dispose();
    _currencyCodeController.dispose();
    _currencyNameController.dispose();
    _regionController.dispose();
    _subRegionController.dispose();
    super.dispose();
  }

  String? _required(String? value, String message) =>
      (value == null || value.trim().isEmpty) ? message : null;

  String? _length(String? value, int length, String message) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim().length != length ? message : null;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      CreateCountryRequest(
        name: _nameController.text.trim(),
        alias: _blankToNull(_aliasController.text),
        iso2Code: _iso2Controller.text.trim().toUpperCase(),
        iso3Code: _iso3Controller.text.trim().toUpperCase(),
        numericCode: _numericController.text.trim(),
        phoneCode: _phoneController.text.trim(),
        currencyCode: _currencyCodeController.text.trim().toUpperCase(),
        currencyName: _currencyNameController.text.trim(),
        region: _blankToNull(_regionController.text),
        subRegion: _blankToNull(_subRegionController.text),
      ),
    );
  }

  static String? _blankToNull(String value) =>
      value.trim().isEmpty ? null : value.trim();

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
              Icons.public_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text('Add country'),
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
                  hintText: 'e.g. India',
                  prefixIcon: Icon(Icons.public_rounded),
                ),
                validator: (value) =>
                    _required(value, 'Enter a country name'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _aliasController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Alias (optional)',
                  hintText: 'e.g. Bharat',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _iso2Controller,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 2,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                        _UpperCaseTextFormatter(),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'ISO2 code',
                        hintText: 'IN',
                        counterText: '',
                        prefixIcon: Icon(Icons.tag_rounded),
                      ),
                      validator: (value) => _required(value, 'ISO2 required') ??
                          _length(value, 2, 'Must be exactly 2 characters'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _iso3Controller,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 3,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                        _UpperCaseTextFormatter(),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'ISO3 code',
                        hintText: 'IND',
                        counterText: '',
                        prefixIcon: Icon(Icons.tag_rounded),
                      ),
                      validator: (value) => _required(value, 'ISO3 required') ??
                          _length(value, 3, 'Exactly 3 characters'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _numericController,
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Numeric code',
                        hintText: '356',
                        counterText: '',
                        prefixIcon: Icon(Icons.pin_rounded),
                      ),
                      validator: (value) =>
                          _required(value, 'Numeric code required') ??
                          _length(value, 3, 'Exactly 3 characters'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone code',
                        hintText: '+91',
                        prefixIcon: Icon(Icons.call_rounded),
                      ),
                      validator: (value) =>
                          _required(value, 'Phone code required'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _SectionLabel('Currency'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _currencyCodeController,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 3,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                        _UpperCaseTextFormatter(),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Currency code',
                        hintText: 'INR',
                        counterText: '',
                        prefixIcon: Icon(Icons.currency_exchange_rounded),
                      ),
                      validator: (value) =>
                          _required(value, 'Currency code required') ??
                          _length(value, 3, 'Exactly 3 characters'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _currencyNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Currency name',
                        hintText: 'Indian Rupee',
                        prefixIcon: Icon(Icons.payments_rounded),
                      ),
                      validator: (value) =>
                          _required(value, 'Currency name required'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _SectionLabel('Region (optional)'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _regionController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Region',
                        hintText: 'e.g. Asia',
                        prefixIcon: Icon(Icons.language_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _subRegionController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Sub-region',
                        hintText: 'e.g. Southern Asia',
                        prefixIcon: Icon(Icons.travel_explore_rounded),
                      ),
                    ),
                  ),
                ],
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
