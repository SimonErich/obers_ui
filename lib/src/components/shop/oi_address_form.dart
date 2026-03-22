import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_address_data.dart';
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
    super.key,
  });

  /// Creates an [OiAddressForm] pre-labelled for shipping addresses.
  const OiAddressForm.shipping({
    this.initialData = const OiAddressData(),
    this.onChanged,
    this.enabled = true,
    super.key,
  }) : label = 'Shipping address';

  /// Creates an [OiAddressForm] pre-labelled for billing addresses.
  const OiAddressForm.billing({
    this.initialData = const OiAddressData(),
    this.onChanged,
    this.enabled = true,
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

  void _notifyChanged() {
    widget.onChanged?.call(
      OiAddressData(
        firstName: _emptyToNull(_firstNameCtrl.text),
        lastName: _emptyToNull(_lastNameCtrl.text),
        company: _emptyToNull(_companyCtrl.text),
        line1: _emptyToNull(_line1Ctrl.text),
        line2: _emptyToNull(_line2Ctrl.text),
        city: _emptyToNull(_cityCtrl.text),
        state: _emptyToNull(_stateCtrl.text),
        postalCode: _emptyToNull(_postalCodeCtrl.text),
        country: _emptyToNull(_countryCtrl.text),
        phone: _emptyToNull(_phoneCtrl.text),
        email: _emptyToNull(_emailCtrl.text),
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
          OiRow(
            breakpoint: breakpoint,
            gap: OiResponsive(sp.sm),
            children: [
              Expanded(
                child: OiTextInput(
                  controller: _firstNameCtrl,
                  label: 'First name',
                  placeholder: 'First name',
                  enabled: widget.enabled,
                  onChanged: (_) => _notifyChanged(),
                ),
              ),
              Expanded(
                child: OiTextInput(
                  controller: _lastNameCtrl,
                  label: 'Last name',
                  placeholder: 'Last name',
                  enabled: widget.enabled,
                  onChanged: (_) => _notifyChanged(),
                ),
              ),
            ],
          ),
          OiTextInput(
            controller: _companyCtrl,
            label: 'Company',
            placeholder: 'Company (optional)',
            enabled: widget.enabled,
            onChanged: (_) => _notifyChanged(),
          ),
          OiTextInput(
            controller: _line1Ctrl,
            label: 'Address line 1',
            placeholder: 'Street address',
            enabled: widget.enabled,
            onChanged: (_) => _notifyChanged(),
          ),
          OiTextInput(
            controller: _line2Ctrl,
            label: 'Address line 2',
            placeholder: 'Apartment, suite, etc. (optional)',
            enabled: widget.enabled,
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
                  enabled: widget.enabled,
                  onChanged: (_) => _notifyChanged(),
                ),
              ),
              Expanded(
                child: OiTextInput(
                  controller: _stateCtrl,
                  label: 'State / Province',
                  placeholder: 'State / Province',
                  enabled: widget.enabled,
                  onChanged: (_) => _notifyChanged(),
                ),
              ),
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
                  enabled: widget.enabled,
                  onChanged: (_) => _notifyChanged(),
                ),
              ),
              Expanded(
                child: OiTextInput(
                  controller: _countryCtrl,
                  label: 'Country',
                  placeholder: 'Country',
                  enabled: widget.enabled,
                  onChanged: (_) => _notifyChanged(),
                ),
              ),
            ],
          ),
          OiRow(
            breakpoint: breakpoint,
            gap: OiResponsive(sp.sm),
            children: [
              Expanded(
                child: OiTextInput(
                  controller: _phoneCtrl,
                  label: 'Phone',
                  placeholder: 'Phone number',
                  enabled: widget.enabled,
                  onChanged: (_) => _notifyChanged(),
                ),
              ),
              Expanded(
                child: OiTextInput(
                  controller: _emailCtrl,
                  label: 'Email',
                  placeholder: 'Email address',
                  enabled: widget.enabled,
                  onChanged: (_) => _notifyChanged(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
