import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../../address/models/create_address_request.dart';
import '../../country/models/country.dart';
import '../../financial_year/models/create_financial_year_request.dart';
import '../../financial_year/models/financial_year.dart';
import '../../financial_year/viewModel/financial_year_view_model.dart';
import '../../financial_year/widgets/financial_year_add_dialog.dart';
import '../../financial_year/widgets/financial_year_badge.dart';
import '../../state/models/state_master.dart';
import '../../state/viewModel/state_view_model.dart';
import '../models/create_company_request.dart';
import '../screens/company_add_screen.dart';

/// `bookCommencingFrom` is sent to the backend as ISO `yyyy-MM-dd`.
String _toIsoDateString(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// State for [CompanyAddScreen]. Kept out of the screen file to follow the
/// StatefulWidget split pattern.
class CompanyAddScreenState extends State<CompanyAddScreen> {
  static const double _wideBreakpoint = 760;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mailingNameController = TextEditingController();
  final _line1Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _mobileController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _faxController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();

  FinancialYear? _financialYear;
  DateTime? _bookBeginFrom;
  String? _dateError;
  Country? _country;
  StateMaster? _state;
  String _addressType = kCommonAddressTypes.first;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final financialYearViewModel = context.read<FinancialYearViewModel>();
      if (financialYearViewModel.financialYears.isEmpty) {
        financialYearViewModel.loadFinancialYears();
      }
      final stateViewModel = context.read<StateViewModel>();
      if (stateViewModel.countries.isEmpty) stateViewModel.loadCountries();
      if (stateViewModel.states.isEmpty) stateViewModel.loadStates();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mailingNameController.dispose();
    _line1Controller.dispose();
    _cityController.dispose();
    _pinCodeController.dispose();
    _mobileController.dispose();
    _telephoneController.dispose();
    _faxController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _createFinancialYear() async {
    final result = await showDialog<CreateFinancialYearRequest>(
      context: context,
      builder: (_) => const FinancialYearAddDialog(),
    );
    if (result == null || !mounted) return;
    final viewModel = context.read<FinancialYearViewModel>();
    final success = await viewModel.addFinancialYear(result);
    if (!mounted || !success) return;
    final created = viewModel.financialYears
        .where((year) => year.name == result.name)
        .lastOrNull;
    if (created != null) setState(() => _financialYear = created);
  }

  Future<void> _pickBookBeginFrom() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _bookBeginFrom ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10, 12, 31),
    );
    if (picked == null) return;
    setState(() {
      _bookBeginFrom = picked;
      _dateError = null;
    });
  }

  void _submit() {
    final formValid = _formKey.currentState?.validate() ?? false;
    final financialYear = _financialYear;
    final bookBeginFrom = _bookBeginFrom;
    final country = _country;
    final state = _state;
    if (bookBeginFrom == null) {
      setState(() => _dateError = 'Select the books-beginning date.');
    }
    if (!formValid ||
        financialYear == null ||
        bookBeginFrom == null ||
        country == null ||
        state == null) {
      return;
    }

    Navigator.of(context).pop(
      CreateCompanyRequest(
        name: _nameController.text.trim(),
        financialYearId: financialYear.id,
        bookCommencingFrom: _toIsoDateString(bookBeginFrom),
        mailingName: _mailingNameController.text.trim(),
        telephoneNo: _telephoneController.text.trim().isEmpty
            ? null
            : _telephoneController.text.trim(),
        mobileNo: _mobileController.text.trim(),
        faxNo: _faxController.text.trim().isEmpty
            ? null
            : _faxController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        website: _websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim(),
        address: CreateAddressRequest(
          addressType: _addressType,
          line1: _line1Controller.text.trim(),
          city: _cityController.text.trim().isEmpty
              ? null
              : _cityController.text.trim(),
          stateId: state.id,
          countryId: country.id,
          pinCode: _pinCodeController.text.trim(),
          // Not editable on the create form: the first address is always the
          // primary one and starts out active.
          isPrimary: true,
          mobileNo: _mobileController.text.trim().isEmpty
              ? null
              : _mobileController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final financialYears = context
        .watch<FinancialYearViewModel>()
        .financialYears;
    final stateViewModel = context.watch<StateViewModel>();
    final countries = stateViewModel.countries;
    final allStates = stateViewModel.states;
    final states = _country == null
        ? allStates
        : allStates.where((s) => s.countryId == _country!.id).toList();
    final isWide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;

    final left = _LeftPanel(
      nameController: _nameController,
      mailingNameController: _mailingNameController,
      line1Controller: _line1Controller,
      cityController: _cityController,
      pinCodeController: _pinCodeController,
      mobileController: _mobileController,
      emailController: _emailController,
      addressType: _addressType,
      onAddressTypeChanged: (value) =>
          setState(() => _addressType = value ?? _addressType),
      countries: countries,
      country: _country,
      onCountryChanged: (value) => setState(() {
        _country = value;
        if (_state != null && value != null && _state!.countryId != value.id) {
          _state = null;
        }
      }),
      states: states,
      state: _state,
      onStateChanged: (value) => setState(() => _state = value),
    );
    final right = _RightPanel(
      financialYears: financialYears,
      financialYear: _financialYear,
      onFinancialYearChanged: (value) => setState(() => _financialYear = value),
      bookBeginFrom: _bookBeginFrom,
      dateError: _dateError,
      onPickBookBeginFrom: _pickBookBeginFrom,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Create company'),
            const SizedBox(width: 16),
            FinancialYearBadge(financialYear: _financialYear),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Add financial year',
              onPressed: _createFinancialYear,
              icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: _CompactFormTheme(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: left),
                          const SizedBox(width: 20),
                          Expanded(child: right),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [left, const SizedBox(height: 16), right],
                      ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shrinks field and text sizing for the whole form: dense input
/// decoration, smaller icons, and a slightly reduced text scale.
class _CompactFormTheme extends StatelessWidget {
  const _CompactFormTheme({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(fontSizeFactor: 0.9),
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
      child: IconTheme.merge(data: const IconThemeData(size: 18), child: child),
    );
  }
}

/// Left column: Directory, Name, then the "Primary Mailing Details" section
/// (mailing name, address type, address line 1, city, country, state, pin
/// code).
class _LeftPanel extends StatelessWidget {
  const _LeftPanel({
    required this.nameController,
    required this.mailingNameController,
    required this.line1Controller,
    required this.cityController,
    required this.pinCodeController,
    required this.mobileController,
    required this.emailController,
    required this.addressType,
    required this.onAddressTypeChanged,
    required this.countries,
    required this.country,
    required this.onCountryChanged,
    required this.states,
    required this.state,
    required this.onStateChanged,
  });

  final TextEditingController nameController;
  final TextEditingController mailingNameController;
  final TextEditingController line1Controller;
  final TextEditingController cityController;
  final TextEditingController pinCodeController;
  final TextEditingController mobileController;
  final TextEditingController emailController;
  final String addressType;
  final ValueChanged<String?> onAddressTypeChanged;
  final List<Country> countries;
  final Country? country;
  final ValueChanged<Country?> onCountryChanged;
    final List<StateMaster> states;
    final StateMaster? state;
    final ValueChanged<StateMaster?> onStateChanged;

    @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LabeledField(
          label: 'Directory',
          child: Text(
            'Default',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _LabeledField(
          label: 'Name',
          child: TextFormField(
            controller: nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'e.g. Acme Traders'),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Enter a company name'
                : null,
          ),
        ),
        const SizedBox(height: 16),
        const _SectionLabel('Primary Mailing Details'),
        const SizedBox(height: 8),
        _LabeledField(
          label: 'Mailing name',
          child: TextFormField(
            controller: mailingNameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'e.g. Acme Traders'),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Enter a mailing name'
                : null,
          ),
        ),
        const SizedBox(height: 10),
        _LabeledField(
          label: 'Address type',
          child: DropdownButtonFormField<String>(
            initialValue: addressType,
            decoration: const InputDecoration(),
            items: [
              for (final type in kCommonAddressTypes)
                DropdownMenuItem(value: type, child: Text(type)),
            ],
            onChanged: onAddressTypeChanged,
          ),
        ),
        const SizedBox(height: 10),
        _LabeledField(
          label: 'Address',
          child: TextFormField(
            controller: line1Controller,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Building, street, door no.',
            ),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Enter the address'
                : null,
          ),
        ),
        const SizedBox(height: 10),
        _LabeledField(
          label: 'City',
          child: TextFormField(
            controller: cityController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'e.g. Mumbai'),
          ),
        ),
        const SizedBox(height: 10),
        _LabeledField(
          label: 'Country',
          child: DropdownButtonFormField<Country>(
            initialValue: country,
            decoration: const InputDecoration(),
            items: [
              for (final item in countries)
                DropdownMenuItem(value: item, child: Text(item.name)),
            ],
            onChanged: onCountryChanged,
            validator: (value) => value == null ? 'Select a country' : null,
          ),
        ),
        const SizedBox(height: 10),
        _LabeledField(
          label: 'State',
          child: DropdownButtonFormField<StateMaster>(
            initialValue: state,
            decoration: const InputDecoration(),
            items: [
              for (final item in states)
                DropdownMenuItem(value: item, child: Text(item.name)),
            ],
            onChanged: onStateChanged,
            validator: (value) => value == null ? 'Select a state' : null,
          ),
        ),
        const SizedBox(height: 10),
        _LabeledField(
          label: 'Pin code',
          child: TextFormField(
            controller: pinCodeController,
            keyboardType: TextInputType.number,
            maxLength: 10,
            decoration: const InputDecoration(
              hintText: 'e.g. 400001',
              counterText: '',
            ),
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) return 'Enter the pin code';
              if (trimmed.length < 3 || trimmed.length > 10) {
                return 'Must be 3–10 characters';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 12),
        const _SectionLabel('Contact Details'),
        const SizedBox(height: 8),
        _LabeledField(
          label: 'Mobile number',
          child: TextFormField(
            controller: mobileController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: 'Optional'),
          ),
        ),
        const SizedBox(height: 10),
        _LabeledField(
          label: 'Email',
          child: TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'Optional'),
          ),
        ),
      ],
    );
  }
}

/// Right column: everything to do with the company's books.
class _RightPanel extends StatelessWidget {
  const _RightPanel({
    required this.financialYears,
    required this.financialYear,
    required this.onFinancialYearChanged,
    required this.bookBeginFrom,
    required this.dateError,
    required this.onPickBookBeginFrom,
  });

  final List<FinancialYear> financialYears;
  final FinancialYear? financialYear;
  final ValueChanged<FinancialYear?> onFinancialYearChanged;
  final DateTime? bookBeginFrom;
  final String? dateError;
  final VoidCallback onPickBookBeginFrom;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionLabel('Books'),
        const SizedBox(height: 8),
        _LabeledField(
          label: 'Financial year',
          child: DropdownButtonFormField<FinancialYear>(
            initialValue: financialYear,
            decoration: const InputDecoration(),
            items: [
              for (final year in financialYears)
                DropdownMenuItem(value: year, child: Text(year.name)),
            ],
            onChanged: onFinancialYearChanged,
            validator: (value) =>
                value == null ? 'Select a financial year' : null,
          ),
        ),
        const SizedBox(height: 10),
        _LabeledField(
          label: 'Books begin from',
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onPickBookBeginFrom,
            child: InputDecorator(
              decoration: InputDecoration(
                suffixIcon: const Icon(Icons.calendar_today_rounded, size: 14),
                errorText: dateError,
              ),
              child: Text(
                bookBeginFrom == null
                    ? 'Select'
                    : _toIsoDateString(bookBeginFrom!),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: bookBeginFrom == null
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A form row laid out as `label: input` — a fixed-width label on the left,
/// the field taking the remaining width on the right.
class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  static const double _labelWidth = 148;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: _labelWidth,
          child: Text(
            '$label:',
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: child),
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
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );
  }
}
