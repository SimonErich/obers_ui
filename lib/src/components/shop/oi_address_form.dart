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
/// Coverage: REQ-0001, REQ-0002, REQ-0003
///
/// Renders labelled text inputs for first name, last name, company (optional),
/// address line 1, address line 2 (optional), city, state/province, postal
/// code, country, and phone. Calls [onChange] with an updated
/// [OiAddressData] whenever a field changes.
///
/// Pre-populate by passing an [initialValue] value.
///
/// On wide breakpoints (≥ [OiBreakpoint.medium]), paired fields (name, city +
/// state, postal code + country) render side by side in [OiRow]. On narrow
/// breakpoints all fields stack vertically in [OiColumn].
///
/// {@category Components}
class OiAddressForm extends StatefulWidget {
  /// Creates an [OiAddressForm].
  const OiAddressForm({
    required this.label,
    this.initialValue,
    this.onChange,
    this.onSubmit,
    this.countries,
    this.showCompany = true,
    this.showPhone = true,
    this.showName = true,
    this.readOnly = false,
    this.error,
    super.key,
  });

  /// Creates an [OiAddressForm] pre-labelled for shipping addresses.
  const OiAddressForm.shipping({
    this.initialValue,
    this.onChange,
    this.onSubmit,
    this.countries,
    this.showCompany = true,
    this.showPhone = true,
    this.showName = true,
    this.readOnly = false,
    this.error,
    super.key,
  }) : label = 'Shipping address';

  /// Creates an [OiAddressForm] pre-labelled for billing addresses.
  const OiAddressForm.billing({
    this.initialValue,
    this.onChange,
    this.onSubmit,
    this.countries,
    this.showCompany = true,
    this.showPhone = true,
    this.showName = true,
    this.readOnly = false,
    this.error,
    super.key,
  }) : label = 'Billing address';

  /// Accessibility label for the form region.
  final String label;

  /// Initial address values to pre-fill. When `null`, all fields start empty.
  final OiAddressData? initialValue;

  /// Called whenever a field value changes with the latest [OiAddressData].
  final ValueChanged<OiAddressData>? onChange;

  /// Called when the form is submitted with valid data.
  /// Validation runs before calling — if any required field is empty, inline
  /// errors are shown and [onSubmit] is not called.
  final ValueChanged<OiAddressData>? onSubmit;

  /// Optional list of country options. When provided, the country field
  /// renders as an [OiSelect] dropdown instead of a plain text input.
  /// Countries with [OiCountryOption.states] cause the state field to render
  /// as a dropdown; otherwise the state field is a text input.
  final List<OiCountryOption>? countries;

  /// Whether to show the company field. Defaults to `true`.
  final bool showCompany;

  /// Whether to show the phone field. Defaults to `true`.
  final bool showPhone;

  /// Whether to show the first name and last name fields. Defaults to `true`.
  final bool showName;

  /// Whether the form is read-only. When `true`, all inputs are non-editable
  /// and all selects are disabled.
  final bool readOnly;

  /// An optional global error message for the form.
  final String? error;

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

  String? _selectedCountryCode;
  String? _selectedStateValue;
  Map<String, String>? _validationErrors;

  @override
  void initState() {
    super.initState();
    final d = widget.initialValue;
    _firstNameCtrl = TextEditingController(text: d?.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: d?.lastName ?? '');
    _companyCtrl = TextEditingController(text: d?.company ?? '');
    _line1Ctrl = TextEditingController(text: d?.line1 ?? '');
    _line2Ctrl = TextEditingController(text: d?.line2 ?? '');
    _cityCtrl = TextEditingController(text: d?.city ?? '');
    _stateCtrl = TextEditingController(text: d?.state ?? '');
    _postalCodeCtrl = TextEditingController(text: d?.postalCode ?? '');
    _countryCtrl = TextEditingController(text: d?.country ?? '');
    _phoneCtrl = TextEditingController(text: d?.phone ?? '');

    // Resolve initial country code from countries list.
    if (widget.countries != null && d?.country != null) {
      final match = widget.countries!.where(
        (c) => c.code == d!.country || c.name == d.country,
      );
      if (match.isNotEmpty) {
        _selectedCountryCode = match.first.code;
      }
    }

    // Resolve initial state value.
    if (d?.state != null && d!.state!.isNotEmpty) {
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
    super.dispose();
  }

  String? _emptyToNull(String v) => v.trim().isEmpty ? null : v.trim();

  OiAddressData _buildCurrentData() {
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
    );
  }

  void _onFieldChanged() {
    widget.onChange?.call(_buildCurrentData());
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
    widget.onSubmit?.call(_buildCurrentData());
  }

  String? _validationErrorFor(String field) {
    return _validationErrors?[field];
  }

  // ── Field builders ──────────────────────────────────────────────────────

  Widget _buildNameRow(bool isWide) {
    final firstName = OiTextInput(
      controller: _firstNameCtrl,
      label: 'First name',
      placeholder: 'First name',
      readOnly: widget.readOnly,
      enabled: !widget.readOnly,
      error: _validationErrorFor('firstName'),
      onChanged: (_) => _onFieldChanged(),
    );
    final lastName = OiTextInput(
      controller: _lastNameCtrl,
      label: 'Last name',
      placeholder: 'Last name',
      readOnly: widget.readOnly,
      enabled: !widget.readOnly,
      error: _validationErrorFor('lastName'),
      onChanged: (_) => _onFieldChanged(),
    );

    if (!isWide) {
      return OiColumn(
        breakpoint: context.breakpoint,
        gap: OiResponsive(context.spacing.md),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [firstName, lastName],
      );
    }

    return OiRow(
      breakpoint: context.breakpoint,
      gap: OiResponsive(context.spacing.sm),
      children: [Expanded(child: firstName), Expanded(child: lastName)],
    );
  }

  List<Widget> _buildAddressFields() {
    return [
      OiTextInput(
        controller: _line1Ctrl,
        label: 'Address line 1',
        placeholder: 'Street address',
        readOnly: widget.readOnly,
        enabled: !widget.readOnly,
        error: _validationErrorFor('line1'),
        onChanged: (_) => _onFieldChanged(),
      ),
      OiTextInput(
        controller: _line2Ctrl,
        label: 'Address line 2',
        placeholder: 'Apartment, suite, etc. (optional)',
        readOnly: widget.readOnly,
        enabled: !widget.readOnly,
        error: _validationErrorFor('line2'),
        onChanged: (_) => _onFieldChanged(),
      ),
    ];
  }

  Widget _buildStateFieldRaw() {
    final country = _selectedCountry;
    if (country != null &&
        country.states != null &&
        country.states!.isNotEmpty) {
      return OiSelect<String>(
        label: 'State / Province',
        placeholder: 'State / Province',
        value: _selectedStateValue,
        options: country.states!
            .map((s) => OiSelectOption<String>(value: s.code, label: s.name))
            .toList(),
        enabled: !widget.readOnly,
        error: _validationErrorFor('state'),
        onChanged: (value) {
          setState(() => _selectedStateValue = value);
          _onFieldChanged();
        },
      );
    }
    return OiTextInput(
      controller: _stateCtrl,
      label: 'State / Province',
      placeholder: 'State / Province',
      readOnly: widget.readOnly,
      enabled: !widget.readOnly,
      error: _validationErrorFor('state'),
      onChanged: (_) => _onFieldChanged(),
    );
  }

  Widget _buildCityStateRow(bool isWide) {
    final city = OiTextInput(
      controller: _cityCtrl,
      label: 'City',
      placeholder: 'City',
      readOnly: widget.readOnly,
      enabled: !widget.readOnly,
      error: _validationErrorFor('city'),
      onChanged: (_) => _onFieldChanged(),
    );
    final state = _buildStateFieldRaw();

    if (!isWide) {
      return OiColumn(
        breakpoint: context.breakpoint,
        gap: OiResponsive(context.spacing.md),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [city, state],
      );
    }

    return OiRow(
      breakpoint: context.breakpoint,
      gap: OiResponsive(context.spacing.sm),
      children: [Expanded(child: city), Expanded(child: state)],
    );
  }

  Widget _buildCountryFieldRaw() {
    if (widget.countries != null && widget.countries!.isNotEmpty) {
      return OiSelect<String>(
        label: 'Country',
        placeholder: 'Country',
        value: _selectedCountryCode,
        options: widget.countries!
            .map((c) => OiSelectOption<String>(value: c.code, label: c.name))
            .toList(),
        enabled: !widget.readOnly,
        error: _validationErrorFor('country'),
        onChanged: (code) {
          setState(() {
            _selectedCountryCode = code;
            // Reset state when country changes.
            _selectedStateValue = null;
            _stateCtrl.text = '';
          });
          _onFieldChanged();
        },
      );
    }
    return OiTextInput(
      controller: _countryCtrl,
      label: 'Country',
      placeholder: 'Country',
      readOnly: widget.readOnly,
      enabled: !widget.readOnly,
      error: _validationErrorFor('country'),
      onChanged: (_) => _onFieldChanged(),
    );
  }

  Widget _buildPostalCountryRow(bool isWide) {
    final postalCode = OiTextInput(
      controller: _postalCodeCtrl,
      label: 'Postal code',
      placeholder: 'Postal code',
      readOnly: widget.readOnly,
      enabled: !widget.readOnly,
      error: _validationErrorFor('postalCode'),
      onChanged: (_) => _onFieldChanged(),
    );
    final country = _buildCountryFieldRaw();

    if (!isWide) {
      return OiColumn(
        breakpoint: context.breakpoint,
        gap: OiResponsive(context.spacing.md),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [postalCode, country],
      );
    }

    return OiRow(
      breakpoint: context.breakpoint,
      gap: OiResponsive(context.spacing.sm),
      children: [Expanded(child: postalCode), Expanded(child: country)],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;
    final isWide = context.isMediumOrWider;

    return Semantics(
      label: widget.label,
      child: OiColumn(
        breakpoint: breakpoint,
        gap: OiResponsive(sp.md),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OiLabel.bodyStrong(widget.label),
          if (widget.showName) _buildNameRow(isWide),
          if (widget.showCompany)
            OiTextInput(
              controller: _companyCtrl,
              label: 'Company',
              placeholder: 'Company (optional)',
              readOnly: widget.readOnly,
              enabled: !widget.readOnly,
              error: _validationErrorFor('company'),
              onChanged: (_) => _onFieldChanged(),
            ),
          ..._buildAddressFields(),
          _buildCityStateRow(isWide),
          _buildPostalCountryRow(isWide),
          if (widget.showPhone)
            OiTextInput(
              controller: _phoneCtrl,
              label: 'Phone',
              placeholder: 'Phone number',
              readOnly: widget.readOnly,
              enabled: !widget.readOnly,
              error: _validationErrorFor('phone'),
              onChanged: (_) => _onFieldChanged(),
            ),
          if (widget.error != null) OiLabel.small(widget.error!),
        ],
      ),
    );
  }

  /// Triggers validation and submit. Exposed for testing via GlobalKey.
  void submit() => _handleSubmit();
}
