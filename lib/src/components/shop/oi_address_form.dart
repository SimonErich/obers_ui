import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/inputs/oi_select.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_address_data.dart';
import 'package:obers_ui/src/models/oi_country_option.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';

/// A form for entering a postal / shipping address.
///
/// Coverage: REQ-0022
///
/// Renders labelled text inputs for first name, last name, company (optional),
/// address line 1, address line 2 (optional), city, state/province, postal
/// code, country, phone, and email. Calls [onChanged] with an updated
/// [OiAddressData] whenever a field changes.
///
/// Pre-populate by passing an [initialData] value.
///
/// {@category Components}
class OiAddressForm extends StatefulWidget {
  /// Creates an [OiAddressForm].
  const OiAddressForm({
    required this.label,
    this.initialData = const OiAddressData(),
    this.onChanged,
    this.enabled = true,
    this.showName = true,
    this.showCompany = true,
    this.showPhone = true,
    this.countries,
    this.readOnly = false,
    this.onSubmit,
    this.error,
    super.key,
  });

  /// Creates an [OiAddressForm] pre-labelled for shipping addresses.
  const OiAddressForm.shipping({
    this.initialData = const OiAddressData(),
    this.onChanged,
    this.enabled = true,
    this.showName = true,
    this.showCompany = true,
    this.showPhone = true,
    this.countries,
    this.readOnly = false,
    this.onSubmit,
    this.error,
    super.key,
  }) : label = 'Shipping address';

  /// Creates an [OiAddressForm] pre-labelled for billing addresses.
  const OiAddressForm.billing({
    this.initialData = const OiAddressData(),
    this.onChanged,
    this.enabled = true,
    this.showName = true,
    this.showCompany = true,
    this.showPhone = true,
    this.countries,
    this.readOnly = false,
    this.onSubmit,
    this.error,
    super.key,
  }) : label = 'Billing address';

  /// Accessibility label for the form region.
  final String label;

  /// Initial address values to pre-fill. Defaults to empty.
  final OiAddressData initialData;

  /// Called whenever a field value changes with the latest [OiAddressData].
  final ValueChanged<OiAddressData>? onChanged;

  /// Whether the form inputs are enabled. Defaults to `true`.
  final bool enabled;

  /// Whether to show the first name and last name fields. Defaults to `true`.
  final bool showName;

  /// Whether to show the company field. Defaults to `true`.
  final bool showCompany;

  /// Whether to show the phone field. Defaults to `true`.
  final bool showPhone;

  /// Optional list of country options. When provided, the country field
  /// renders as an [OiSelect] dropdown instead of a plain text input.
  /// Countries with [OiCountryOption.states] cause the state field to render
  /// as a dropdown; otherwise the state field is a text input.
  final List<OiCountryOption>? countries;

  /// Whether the form is read-only. When `true`, all inputs are non-editable.
  /// Takes precedence over [enabled].
  final bool readOnly;

  /// Called when the form is submitted with valid data.
  /// Validation runs before calling — if any required field is empty, inline
  /// errors are shown and [onSubmit] is not called.
  final ValueChanged<OiAddressData>? onSubmit;

  /// Per-field error messages keyed by field name (e.g. `{'line1': 'Required'}`).
  /// Supported keys: `firstName`, `lastName`, `company`, `line1`, `line2`,
  /// `city`, `state`, `postalCode`, `country`, `phone`, `email`.
  final Map<String, String>? error;

  /// Whether the fields are effectively interactive.
  bool get _isInteractive => enabled && !readOnly;

  @override
  State<OiAddressForm> createState() => _OiAddressFormState();
}

class _OiAddressFormState extends State<OiAddressForm> {
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _companyCtrl;
  late final TextEditingController _line1Ctrl;
  late final TextEditingController _line2Ctrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _postalCodeCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;

  String? _selectedCountryCode;
  String? _selectedStateValue;
  Map<String, String>? _validationErrors;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _firstNameCtrl = TextEditingController(text: d.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: d.lastName ?? '');
    _companyCtrl = TextEditingController(text: d.company ?? '');
    _line1Ctrl = TextEditingController(text: d.line1 ?? '');
    _line2Ctrl = TextEditingController(text: d.line2 ?? '');
    _cityCtrl = TextEditingController(text: d.city ?? '');
    _stateCtrl = TextEditingController(text: d.state ?? '');
    _postalCodeCtrl = TextEditingController(text: d.postalCode ?? '');
    _countryCtrl = TextEditingController(text: d.country ?? '');
    _phoneCtrl = TextEditingController(text: d.phone ?? '');
    _emailCtrl = TextEditingController(text: d.email ?? '');

    // Resolve initial country code from countries list.
    if (widget.countries != null && d.country != null) {
      final match = widget.countries!.where(
        (c) => c.code == d.country || c.name == d.country,
      );
      if (match.isNotEmpty) {
        _selectedCountryCode = match.first.code;
      }
    }

    // Resolve initial state value.
    if (d.state != null && d.state!.isNotEmpty) {
      _selectedStateValue = d.state;
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _companyCtrl.dispose();
    _line1Ctrl.dispose();
    _line2Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _postalCodeCtrl.dispose();
    _countryCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  String? _emptyToNull(String v) => v.trim().isEmpty ? null : v.trim();

  OiAddressData _currentData() {
    final countryValue = widget.countries != null
        ? (_selectedCountryCode != null
              ? widget.countries!
                    .where((c) => c.code == _selectedCountryCode)
                    .firstOrNull
                    ?.name
              : null)
        : _emptyToNull(_countryCtrl.text);

    final stateValue = _selectedCountry?.states != null
        ? _selectedStateValue
        : _emptyToNull(_stateCtrl.text);

    return OiAddressData(
      firstName: _emptyToNull(_firstNameCtrl.text),
      lastName: _emptyToNull(_lastNameCtrl.text),
      company: _emptyToNull(_companyCtrl.text),
      line1: _emptyToNull(_line1Ctrl.text),
      line2: _emptyToNull(_line2Ctrl.text),
      city: _emptyToNull(_cityCtrl.text),
      state: stateValue,
      postalCode: _emptyToNull(_postalCodeCtrl.text),
      country: countryValue,
      phone: _emptyToNull(_phoneCtrl.text),
      email: _emptyToNull(_emailCtrl.text),
    );
  }

  void _notifyChanged() {
    widget.onChanged?.call(_currentData());
  }

  OiCountryOption? get _selectedCountry {
    if (widget.countries == null || _selectedCountryCode == null) return null;
    return widget.countries!
        .where((c) => c.code == _selectedCountryCode)
        .firstOrNull;
  }

  Map<String, String> _validate() {
    final errors = <String, String>{};
    if (_emptyToNull(_line1Ctrl.text) == null) {
      errors['line1'] = 'Street address is required';
    }
    if (_emptyToNull(_cityCtrl.text) == null) {
      errors['city'] = 'City is required';
    }
    if (_emptyToNull(_postalCodeCtrl.text) == null) {
      errors['postalCode'] = 'Postal code is required';
    }
    if (widget.countries != null) {
      if (_selectedCountryCode == null) {
        errors['country'] = 'Country is required';
      }
    } else {
      if (_emptyToNull(_countryCtrl.text) == null) {
        errors['country'] = 'Country is required';
      }
    }
    return errors;
  }

  void _handleSubmit() {
    final errors = _validate();
    if (errors.isNotEmpty) {
      setState(() => _validationErrors = errors);
      return;
    }
    setState(() => _validationErrors = null);
    widget.onSubmit?.call(_currentData());
  }

  String? _errorFor(String field) {
    return widget.error?[field] ?? _validationErrors?[field];
  }

  Widget _buildNameFields(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;
    return OiRow(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.sm),
      children: [
        Expanded(
          child: OiTextInput(
            controller: _firstNameCtrl,
            label: 'First name',
            placeholder: 'First name',
            enabled: widget._isInteractive,
            readOnly: widget.readOnly,
            error: _errorFor('firstName'),
            onChanged: (_) => _notifyChanged(),
          ),
        ),
        Expanded(
          child: OiTextInput(
            controller: _lastNameCtrl,
            label: 'Last name',
            placeholder: 'Last name',
            enabled: widget._isInteractive,
            readOnly: widget.readOnly,
            error: _errorFor('lastName'),
            onChanged: (_) => _notifyChanged(),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyField(BuildContext context) {
    return OiTextInput(
      controller: _companyCtrl,
      label: 'Company',
      placeholder: 'Company (optional)',
      enabled: widget._isInteractive,
      readOnly: widget.readOnly,
      error: _errorFor('company'),
      onChanged: (_) => _notifyChanged(),
    );
  }

  Widget _buildPhoneField(BuildContext context) {
    return Expanded(
      child: OiTextInput(
        controller: _phoneCtrl,
        label: 'Phone',
        placeholder: 'Phone number',
        enabled: widget._isInteractive,
        readOnly: widget.readOnly,
        error: _errorFor('phone'),
        onChanged: (_) => _notifyChanged(),
      ),
    );
  }

  Widget _buildCountryField(BuildContext context) {
    if (widget.countries != null && widget.countries!.isNotEmpty) {
      return Expanded(
        child: OiSelect<String>(
          label: 'Country',
          placeholder: 'Country',
          value: _selectedCountryCode,
          options: widget.countries!
              .map((c) => OiSelectOption<String>(value: c.code, label: c.name))
              .toList(),
          enabled: widget._isInteractive,
          error: _errorFor('country'),
          onChanged: (code) {
            setState(() {
              _selectedCountryCode = code;
              // Reset state when country changes.
              _selectedStateValue = null;
              _stateCtrl.text = '';
            });
            _notifyChanged();
          },
        ),
      );
    }
    return Expanded(
      child: OiTextInput(
        controller: _countryCtrl,
        label: 'Country',
        placeholder: 'Country',
        enabled: widget._isInteractive,
        readOnly: widget.readOnly,
        error: _errorFor('country'),
        onChanged: (_) => _notifyChanged(),
      ),
    );
  }

  Widget _buildStateField(BuildContext context) {
    final country = _selectedCountry;
    if (country != null &&
        country.states != null &&
        country.states!.isNotEmpty) {
      return Expanded(
        child: OiSelect<String>(
          label: 'State / Province',
          placeholder: 'State / Province',
          value: _selectedStateValue,
          options: country.states!
              .map((s) => OiSelectOption<String>(value: s, label: s))
              .toList(),
          enabled: widget._isInteractive,
          error: _errorFor('state'),
          onChanged: (value) {
            setState(() => _selectedStateValue = value);
            _notifyChanged();
          },
        ),
      );
    }
    return Expanded(
      child: OiTextInput(
        controller: _stateCtrl,
        label: 'State / Province',
        placeholder: 'State / Province',
        enabled: widget._isInteractive,
        readOnly: widget.readOnly,
        error: _errorFor('state'),
        onChanged: (_) => _notifyChanged(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;

    return Semantics(
      label: widget.label,
      child: OiColumn(
        breakpoint: breakpoint,
        gap: OiResponsive(sp.md),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OiLabel.bodyStrong(widget.label),
          if (widget.showName) _buildNameFields(context),
          if (widget.showCompany) _buildCompanyField(context),
          OiTextInput(
            controller: _line1Ctrl,
            label: 'Address line 1',
            placeholder: 'Street address',
            enabled: widget._isInteractive,
            readOnly: widget.readOnly,
            error: _errorFor('line1'),
            onChanged: (_) => _notifyChanged(),
          ),
          OiTextInput(
            controller: _line2Ctrl,
            label: 'Address line 2',
            placeholder: 'Apartment, suite, etc. (optional)',
            enabled: widget._isInteractive,
            readOnly: widget.readOnly,
            error: _errorFor('line2'),
            onChanged: (_) => _notifyChanged(),
          ),
          OiRow(
            breakpoint: breakpoint,
            gap: OiResponsive(sp.sm),
            children: [
              Expanded(
                child: OiTextInput(
                  controller: _cityCtrl,
                  label: 'City',
                  placeholder: 'City',
                  enabled: widget._isInteractive,
                  readOnly: widget.readOnly,
                  error: _errorFor('city'),
                  onChanged: (_) => _notifyChanged(),
                ),
              ),
              _buildStateField(context),
            ],
          ),
          OiRow(
            breakpoint: breakpoint,
            gap: OiResponsive(sp.sm),
            children: [
              Expanded(
                child: OiTextInput(
                  controller: _postalCodeCtrl,
                  label: 'Postal code',
                  placeholder: 'Postal code',
                  enabled: widget._isInteractive,
                  readOnly: widget.readOnly,
                  error: _errorFor('postalCode'),
                  onChanged: (_) => _notifyChanged(),
                ),
              ),
              _buildCountryField(context),
            ],
          ),
          OiRow(
            breakpoint: breakpoint,
            gap: OiResponsive(sp.sm),
            children: [
              if (widget.showPhone) _buildPhoneField(context),
              Expanded(
                child: OiTextInput(
                  controller: _emailCtrl,
                  label: 'Email',
                  placeholder: 'Email address',
                  enabled: widget._isInteractive,
                  readOnly: widget.readOnly,
                  error: _errorFor('email'),
                  onChanged: (_) => _notifyChanged(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Triggers validation and submit. Exposed for testing via GlobalKey.
  void submit() => _handleSubmit();
}
