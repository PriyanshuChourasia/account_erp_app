import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../config/theme/app_theme.dart';
import '../../country/models/country.dart';
import '../../state/models/state_master.dart';
import '../../state/viewModel/state_view_model.dart';
import '../models/create_address_request.dart';

/// Reusable address entry form.
///
/// Renders every field of the backend `CreateAddressDTO`, validates them with
/// an internal [Form] and produces a [CreateAddressRequest] through
/// [AddressFormSectionState.validateAndBuild]. Embed it inside any dialog
/// (company create, standalone address create, ...) using a
/// `GlobalKey<AddressFormSectionState>`.
class AddressFormSection extends StatefulWidget {
  const AddressFormSection({super.key});

  @override
  State<AddressFormSection> createState() => AddressFormSectionState();
}

class AddressFormSectionState extends State<AddressFormSection> {
  final _formKey = GlobalKey<FormState>();

  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _areaController = TextEditingController();
  final _postOfficeController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  String _addressType = kCommonAddressTypes.first;
  Country? _country;
  StateMaster? _state;
  bool _isPrimary = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final viewModel = context.read<StateViewModel>();
      if (viewModel.countries.isEmpty) viewModel.loadCountries();
      if (viewModel.states.isEmpty) viewModel.loadStates();
    });
  }

  @override
  void dispose() {
    _line1Controller.dispose();
    _line2Controller.dispose();
    _cityController.dispose();
    _landmarkController.dispose();
    _areaController.dispose();
    _postOfficeController.dispose();
    _pinCodeController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  /// Validates every field and builds the request, or returns null when
  /// something required is missing (validation messages are shown inline).
  CreateAddressRequest? validateAndBuild() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || _country == null || _state == null) return null;
    return CreateAddressRequest(
      addressType: _addressType,
      line1: _line1Controller.text.trim(),
      line2: _blankToNull(_line2Controller.text),
      city: _blankToNull(_cityController.text),
      landmark: _blankToNull(_landmarkController.text),
      area: _blankToNull(_areaController.text),
      postOffice: _blankToNull(_postOfficeController.text),
      stateId: _state!.id,
      countryId: _country!.id,
      pinCode: _pinCodeController.text.trim(),
      latitude: _blankToNull(_latitudeController.text),
      longitude: _blankToNull(_longitudeController.text),
      isPrimary: _isPrimary,
    );
  }

  static String? _blankToNull(String value) =>
      value.trim().isEmpty ? null : value.trim();

  @override
  Widget build(BuildContext context) {
    final stateViewModel = context.watch<StateViewModel>();
    final countries = stateViewModel.countries.isEmpty
        ? Country.demo
        : stateViewModel.countries;
    final allStates = stateViewModel.states.isEmpty
        ? StateMaster.demo
        : stateViewModel.states;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _addressType,
            decoration: const InputDecoration(
              labelText: 'Address type',
              prefixIcon: Icon(Icons.category_rounded),
            ),
            items: [
              for (final type in kCommonAddressTypes)
                DropdownMenuItem(value: type, child: Text(type)),
            ],
            onChanged: (value) =>
                setState(() => _addressType = value ?? _addressType),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _line1Controller,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Line 1',
              hintText: 'Building, street, door no.',
              prefixIcon: Icon(Icons.location_on_rounded),
            ),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Line 1 is required'
                : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _line2Controller,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Line 2 (optional)',
              prefixIcon: Icon(Icons.location_city_rounded),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cityController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    prefixIcon: Icon(Icons.location_city_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _areaController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Area',
                    prefixIcon: Icon(Icons.map_rounded),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _postOfficeController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Post office',
                    prefixIcon: Icon(Icons.local_post_office_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _landmarkController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Landmark',
                    prefixIcon: Icon(Icons.flag_rounded),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _SectionLabel('Region'),
          const SizedBox(height: 8),
          _PickerField<Country>(
            label: 'Country',
            hint: 'Search and select a country',
            icon: Icons.public_rounded,
            options: countries,
            selected: _country,
            display: (country) => country.name,
            searchTerms: (country) => [
              country.name.toLowerCase(),
              if (country.iso2Code != null)
                country.iso2Code!.toLowerCase(),
            ],
            onSelected: (country) =>
                setState(() {
                  _country = country;
                  if (_state != null && _state!.countryId != country.id) {
                    _state = null;
                  }
                }),
            validatorText: 'Select a country',
          ),
          const SizedBox(height: 14),
          _PickerField<StateMaster>(
            label: 'State',
            hint: 'Search and select a state',
            icon: Icons.map_rounded,
            options: _country == null
                ? allStates
                : allStates.where((s) => s.countryId == _country!.id).toList(),
            selected: _state,
            display: (state) => state.name,
            searchTerms: (state) => [
              state.name.toLowerCase(),
              if (state.code != null) state.code!.toLowerCase(),
            ],
            emptyOptionsText: _country == null
                ? 'Select a country first'
                : 'No states for this country',
            onSelected: (state) => setState(() => _state = state),
            validatorText: 'Select a state',
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _pinCodeController,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Pin code',
                    counterText: '',
                    prefixIcon: Icon(Icons.pin_drop_rounded),
                  ),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return 'Pin code is required';
                    if (trimmed.length < 3 || trimmed.length > 10) {
                      return 'Must be 3–10 characters';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _latitudeController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Latitude',
                    prefixIcon: Icon(Icons.explore_rounded),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _longitudeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Longitude',
              prefixIcon: Icon(Icons.navigation_rounded),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Set as primary address'),
            value: _isPrimary,
            onChanged: (value) => setState(() => _isPrimary = value),
          ),
        ],
      ),
    );
  }
}

/// Autocomplete-backed picker shared by the country and state fields.
class _PickerField<T extends Object> extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.options,
    required this.selected,
    required this.display,
    required this.searchTerms,
    required this.onSelected,
    required this.validatorText,
    this.emptyOptionsText,
  });

  final String label;
  final String hint;
  final IconData icon;
  final List<T> options;
  final T? selected;
  final String Function(T item) display;
  final List<String> Function(T item) searchTerms;
  final ValueChanged<T> onSelected;
  final String validatorText;
  final String? emptyOptionsText;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<T>(
      initialValue: TextEditingValue(text: selected == null ? '' : display(selected!)),
      displayStringForOption: display,
      optionsBuilder: (TextEditingValue value) {
        if (options.isEmpty && emptyOptionsText != null) return const [];
        final query = value.text.trim().toLowerCase();
        if (query.isEmpty) return options;
        return options
            .where((item) => searchTerms(item).any((term) => term.contains(query)))
            .toList();
      },
      onSelected: onSelected,
      fieldViewBuilder: (context, controller, focusNode, _) => TextFormField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: label,
          hintText: options.isEmpty ? (emptyOptionsText ?? hint) : hint,
          prefixIcon: Icon(icon),
          suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
        ),
        validator: (_) => selected == null ? validatorText : null,
      ),
      optionsViewBuilder: (context, onSelect, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340, maxHeight: 240),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: [
                  if (options.isEmpty)
                    ListTile(
                      dense: true,
                      enabled: false,
                      title: Text(emptyOptionsText ?? 'No matches'),
                    )
                  else
                    for (final item in options)
                      ListTile(
                        dense: true,
                        leading: Icon(icon, size: 20, color: AppColors.textSecondary),
                        title: Text(display(item)),
                        onTap: () => onSelect(item),
                      ),
                ],
              ),
            ),
          ),
        );
      },
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
