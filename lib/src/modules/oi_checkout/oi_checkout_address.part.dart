part of '../oi_checkout.dart';

// ── Address step: sync, validation, and UI ───────────────────────────────────

extension _OiCheckoutAddress on _OiCheckoutState {
  // ── Address sync ──────────────────────────────────────────────────────────

  void _syncShippingAddress() {
    _shippingAddress = OiAddressData(
      firstName: _shipFirstName.text.isEmpty ? null : _shipFirstName.text,
      lastName: _shipLastName.text.isEmpty ? null : _shipLastName.text,
      line1: _shipAddress1.text.isEmpty ? null : _shipAddress1.text,
      line2: _shipAddress2.text.isEmpty ? null : _shipAddress2.text,
      city: _shipCity.text.isEmpty ? null : _shipCity.text,
      state: _shipState.text.isEmpty ? null : _shipState.text,
      postalCode: _shipPostalCode.text.isEmpty ? null : _shipPostalCode.text,
      country: _shippingAddress.country,
      phone: _shipPhone.text.isEmpty ? null : _shipPhone.text,
      email: _shipEmail.text.isEmpty ? null : _shipEmail.text,
    );
    widget.onShippingAddressChange?.call(_shippingAddress);
  }

  void _syncBillingAddress() {
    _billingAddress = OiAddressData(
      firstName: _billFirstName.text.isEmpty ? null : _billFirstName.text,
      lastName: _billLastName.text.isEmpty ? null : _billLastName.text,
      line1: _billAddress1.text.isEmpty ? null : _billAddress1.text,
      line2: _billAddress2.text.isEmpty ? null : _billAddress2.text,
      city: _billCity.text.isEmpty ? null : _billCity.text,
      state: _billState.text.isEmpty ? null : _billState.text,
      postalCode: _billPostalCode.text.isEmpty ? null : _billPostalCode.text,
      country: _billingAddress.country,
    );
    widget.onBillingAddressChange?.call(_billingAddress);
  }

  // ── Address validation ────────────────────────────────────────────────────

  bool _validateAddress() {
    _syncShippingAddress();
    if (!_sameBilling) _syncBillingAddress();

    final errors = <String, String?>{};
    if (_shipFirstName.text.isEmpty) {
      errors['shipFirstName'] = widget.labels.firstNameRequired;
    }
    if (_shipLastName.text.isEmpty) {
      errors['shipLastName'] = widget.labels.lastNameRequired;
    }
    if (_shipAddress1.text.isEmpty) {
      errors['shipAddress1'] = widget.labels.addressRequired;
    }
    if (_shipCity.text.isEmpty) {
      errors['shipCity'] = widget.labels.cityRequired;
    }
    if (_shipPostalCode.text.isEmpty) {
      errors['shipPostalCode'] = widget.labels.postalCodeRequired;
    }
    if (_shippingAddress.country == null || _shippingAddress.country!.isEmpty) {
      errors['shipCountry'] = widget.labels.countryRequired;
    }

    if (!_sameBilling) {
      if (_billFirstName.text.isEmpty) {
        errors['billFirstName'] = widget.labels.firstNameRequired;
      }
      if (_billLastName.text.isEmpty) {
        errors['billLastName'] = widget.labels.lastNameRequired;
      }
      if (_billAddress1.text.isEmpty) {
        errors['billAddress1'] = widget.labels.addressRequired;
      }
      if (_billCity.text.isEmpty) {
        errors['billCity'] = widget.labels.cityRequired;
      }
      if (_billPostalCode.text.isEmpty) {
        errors['billPostalCode'] = widget.labels.postalCodeRequired;
      }
    }

    _setAddressErrors(errors);
    return errors.isEmpty;
  }

  // ── Address step UI ───────────────────────────────────────────────────────

  Widget _buildAddressStep(BuildContext context) {
    final breakpoint = context.breakpoint;
    final sp = context.spacing;

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.md),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OiLabel.h3(widget.labels.shippingAddress),
        _buildAddressFields(
          context,
          firstNameCtrl: _shipFirstName,
          lastNameCtrl: _shipLastName,
          address1Ctrl: _shipAddress1,
          address2Ctrl: _shipAddress2,
          cityCtrl: _shipCity,
          stateCtrl: _shipState,
          postalCodeCtrl: _shipPostalCode,
          phoneCtrl: _shipPhone,
          emailCtrl: _shipEmail,
          selectedCountry: _shippingAddress.country,
          onCountryChanged: (v) {
            _setShippingCountry(v);
            _syncShippingAddress();
          },
          errorPrefix: 'ship',
          showContactFields: true,
        ),
        OiCheckbox(
          value: _sameBilling,
          label: widget.labels.sameBilling,
          onChanged: (v) => _setSameBilling(sameBilling: v),
        ),
        if (!_sameBilling) ...[
          Padding(
            padding: EdgeInsets.only(top: sp.sm),
            child: OiLabel.h3(widget.labels.billingAddress),
          ),
          _buildAddressFields(
            context,
            firstNameCtrl: _billFirstName,
            lastNameCtrl: _billLastName,
            address1Ctrl: _billAddress1,
            address2Ctrl: _billAddress2,
            cityCtrl: _billCity,
            stateCtrl: _billState,
            postalCodeCtrl: _billPostalCode,
            selectedCountry: _billingAddress.country,
            onCountryChanged: (v) {
              _setBillingCountry(v);
              _syncBillingAddress();
            },
            errorPrefix: 'bill',
          ),
        ],
      ],
    );
  }

  Widget _buildAddressFields(
    BuildContext context, {
    required TextEditingController firstNameCtrl,
    required TextEditingController lastNameCtrl,
    required TextEditingController address1Ctrl,
    required TextEditingController address2Ctrl,
    required TextEditingController cityCtrl,
    required TextEditingController stateCtrl,
    required TextEditingController postalCodeCtrl,
    required String? selectedCountry,
    required ValueChanged<String?> onCountryChanged,
    required String errorPrefix,
    TextEditingController? phoneCtrl,
    TextEditingController? emailCtrl,
    bool showContactFields = false,
  }) {
    final sp = context.spacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: OiTextInput(
                controller: firstNameCtrl,
                label: widget.labels.firstName,
                error: _addressErrors['${errorPrefix}FirstName'],
                onChanged: (_) => _syncShippingAddress(),
              ),
            ),
            SizedBox(width: sp.sm),
            Expanded(
              child: OiTextInput(
                controller: lastNameCtrl,
                label: widget.labels.lastName,
                error: _addressErrors['${errorPrefix}LastName'],
                onChanged: (_) => _syncShippingAddress(),
              ),
            ),
          ],
        ),
        SizedBox(height: sp.sm),
        OiTextInput(
          controller: address1Ctrl,
          label: widget.labels.address,
          error: _addressErrors['${errorPrefix}Address1'],
          onChanged: (_) => _syncShippingAddress(),
        ),
        SizedBox(height: sp.sm),
        OiTextInput(
          controller: address2Ctrl,
          label: widget.labels.address2,
          onChanged: (_) => _syncShippingAddress(),
        ),
        SizedBox(height: sp.sm),
        Row(
          children: [
            Expanded(
              child: OiTextInput(
                controller: cityCtrl,
                label: widget.labels.city,
                error: _addressErrors['${errorPrefix}City'],
                onChanged: (_) => _syncShippingAddress(),
              ),
            ),
            SizedBox(width: sp.sm),
            Expanded(
              child: OiTextInput(
                controller: stateCtrl,
                label: widget.labels.state,
                onChanged: (_) => _syncShippingAddress(),
              ),
            ),
          ],
        ),
        SizedBox(height: sp.sm),
        Row(
          children: [
            Expanded(
              child: OiTextInput(
                controller: postalCodeCtrl,
                label: widget.labels.postalCode,
                error: _addressErrors['${errorPrefix}PostalCode'],
                onChanged: (_) => _syncShippingAddress(),
              ),
            ),
            SizedBox(width: sp.sm),
            Expanded(
              child: widget.countries != null
                  ? OiSelect<String>(
                      options: widget.countries!
                          .map(
                            (c) => OiSelectOption(value: c.code, label: c.name),
                          )
                          .toList(),
                      value: selectedCountry,
                      label: widget.labels.country,
                      error: _addressErrors['${errorPrefix}Country'],
                      placeholder: widget.labels.selectCountry,
                      onChanged: onCountryChanged,
                    )
                  : OiTextInput(
                      label: widget.labels.country,
                      error: _addressErrors['${errorPrefix}Country'],
                      controller: TextEditingController(
                        text: selectedCountry ?? '',
                      ),
                      onChanged: (v) => onCountryChanged(v),
                    ),
            ),
          ],
        ),
        if (showContactFields && phoneCtrl != null) ...[
          SizedBox(height: sp.sm),
          Row(
            children: [
              Expanded(
                child: OiTextInput(
                  controller: phoneCtrl,
                  label: widget.labels.phone,
                  onChanged: (_) => _syncShippingAddress(),
                ),
              ),
              if (emailCtrl != null) ...[
                SizedBox(width: sp.sm),
                Expanded(
                  child: OiTextInput(
                    controller: emailCtrl,
                    label: widget.labels.email,
                    onChanged: (_) => _syncShippingAddress(),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
