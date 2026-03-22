import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/inputs/oi_checkbox.dart';
import 'package:obers_ui/src/components/inputs/oi_select.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/components/navigation/oi_accordion.dart';
import 'package:obers_ui/src/composites/forms/oi_stepper.dart';
import 'package:obers_ui/src/composites/shop/oi_order_summary.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_address_data.dart';
import 'package:obers_ui/src/models/oi_cart_item.dart';
import 'package:obers_ui/src/models/oi_cart_summary.dart';
import 'package:obers_ui/src/models/oi_order_data.dart';
import 'package:obers_ui/src/models/oi_payment_method.dart';
import 'package:obers_ui/src/models/oi_shipping_method.dart';
import 'package:obers_ui/src/primitives/display/oi_divider.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';

/// The steps available in an [OiCheckout] flow.
///
/// {@category Modules}
enum OiCheckoutStep {
  /// Address entry step (shipping + optional billing).
  address,

  /// Shipping method selection step.
  shipping,

  /// Payment method selection step.
  payment,

  /// Order review step with read-only summary.
  review,
}

/// A complete multi-step checkout flow orchestrating address entry, shipping
/// selection, payment selection, and order review as a wizard.
///
/// Coverage: REQ-0067
///
/// Composes [OiStepper], [OiOrderSummary], [OiButton], [OiCheckbox],
/// [OiSelect], [OiTextInput], [OiAccordion].
///
/// Desktop (≥840 dp): two-column layout — wizard left, persistent
/// [OiOrderSummary] right. Mobile (<840 dp): single column with collapsible
/// summary at top. Each step is validated before advancing. The review step
/// shows all selections read-only with "Edit" links back.
///
/// {@category Modules}
class OiCheckout extends StatefulWidget {
  /// Creates an [OiCheckout].
  const OiCheckout({
    required this.items,
    required this.summary,
    required this.label,
    this.steps = const [
      OiCheckoutStep.address,
      OiCheckoutStep.shipping,
      OiCheckoutStep.payment,
      OiCheckoutStep.review,
    ],
    this.onShippingAddressChange,
    this.onBillingAddressChange,
    this.onShippingMethodChange,
    this.onPaymentMethodChange,
    this.onPlaceOrder,
    this.onCancel,
    this.initialShippingAddress,
    this.initialBillingAddress,
    this.shippingMethods,
    this.paymentMethods,
    this.countries,
    this.showSummary = true,
    this.sameBillingDefault = true,
    this.currencyCode = 'USD',
    this.placeOrderLabel,
    super.key,
  });

  /// The cart items being checked out.
  final List<OiCartItem> items;

  /// The cart summary totals.
  final OiCartSummary summary;

  /// Accessibility label announced by screen readers.
  final String label;

  /// The checkout steps in order. Defaults to address → shipping → payment →
  /// review.
  final List<OiCheckoutStep> steps;

  /// Called when the shipping address changes.
  final ValueChanged<OiAddressData>? onShippingAddressChange;

  /// Called when the billing address changes.
  final ValueChanged<OiAddressData>? onBillingAddressChange;

  /// Called when the shipping method changes.
  final ValueChanged<OiShippingMethod>? onShippingMethodChange;

  /// Called when the payment method changes.
  final ValueChanged<OiPaymentMethod>? onPaymentMethodChange;

  /// Called when the user places the order. Should return the completed
  /// [OiOrderData] or throw on failure.
  final Future<OiOrderData> Function()? onPlaceOrder;

  /// Called when the user cancels the checkout.
  final VoidCallback? onCancel;

  /// Initial shipping address pre-filled on the address step.
  final OiAddressData? initialShippingAddress;

  /// Initial billing address pre-filled on the address step.
  final OiAddressData? initialBillingAddress;

  /// Available shipping methods for the shipping step.
  final List<OiShippingMethod>? shippingMethods;

  /// Available payment methods for the payment step.
  final List<OiPaymentMethod>? paymentMethods;

  /// Country options for the address step country selector.
  final List<OiSelectOption<String>>? countries;

  /// Whether to show the order summary panel. Defaults to `true`.
  final bool showSummary;

  /// Whether the "same as shipping" checkbox defaults to checked.
  /// Defaults to `true`.
  final bool sameBillingDefault;

  /// ISO 4217 currency code. Defaults to `'USD'`.
  final String currencyCode;

  /// Custom label for the place-order button. Defaults to `'Place Order'`.
  final String? placeOrderLabel;

  @override
  State<OiCheckout> createState() => _OiCheckoutState();
}

class _OiCheckoutState extends State<OiCheckout> {
  late int _currentStepIndex;
  late OiAddressData _shippingAddress;
  late OiAddressData _billingAddress;
  late bool _sameBilling;
  OiShippingMethod? _selectedShipping;
  OiPaymentMethod? _selectedPayment;
  bool _isPlacingOrder = false;
  String? _orderError;
  final Set<int> _completedSteps = {};
  final Map<String, String?> _addressErrors = {};

  // Text controllers for shipping address fields.
  late final TextEditingController _shipFirstName;
  late final TextEditingController _shipLastName;
  late final TextEditingController _shipAddress1;
  late final TextEditingController _shipAddress2;
  late final TextEditingController _shipCity;
  late final TextEditingController _shipState;
  late final TextEditingController _shipPostalCode;
  late final TextEditingController _shipPhone;
  late final TextEditingController _shipEmail;

  // Text controllers for billing address fields.
  late final TextEditingController _billFirstName;
  late final TextEditingController _billLastName;
  late final TextEditingController _billAddress1;
  late final TextEditingController _billAddress2;
  late final TextEditingController _billCity;
  late final TextEditingController _billState;
  late final TextEditingController _billPostalCode;

  @override
  void initState() {
    super.initState();
    _currentStepIndex = 0;
    _shippingAddress = widget.initialShippingAddress ?? const OiAddressData();
    _billingAddress = widget.initialBillingAddress ?? const OiAddressData();
    _sameBilling = widget.sameBillingDefault;

    // Pre-select defaults.
    if (widget.shippingMethods != null && widget.shippingMethods!.isNotEmpty) {
      _selectedShipping = widget.shippingMethods!.first;
    }
    if (widget.paymentMethods != null && widget.paymentMethods!.isNotEmpty) {
      _selectedPayment =
          widget.paymentMethods!.where((p) => p.isDefault).firstOrNull ??
          widget.paymentMethods!.first;
    }

    _shipFirstName =
        TextEditingController(text: _shippingAddress.firstName ?? '');
    _shipLastName =
        TextEditingController(text: _shippingAddress.lastName ?? '');
    _shipAddress1 =
        TextEditingController(text: _shippingAddress.address1 ?? '');
    _shipAddress2 =
        TextEditingController(text: _shippingAddress.address2 ?? '');
    _shipCity = TextEditingController(text: _shippingAddress.city ?? '');
    _shipState = TextEditingController(text: _shippingAddress.state ?? '');
    _shipPostalCode =
        TextEditingController(text: _shippingAddress.postalCode ?? '');
    _shipPhone = TextEditingController(text: _shippingAddress.phone ?? '');
    _shipEmail = TextEditingController(text: _shippingAddress.email ?? '');

    _billFirstName =
        TextEditingController(text: _billingAddress.firstName ?? '');
    _billLastName =
        TextEditingController(text: _billingAddress.lastName ?? '');
    _billAddress1 =
        TextEditingController(text: _billingAddress.address1 ?? '');
    _billAddress2 =
        TextEditingController(text: _billingAddress.address2 ?? '');
    _billCity = TextEditingController(text: _billingAddress.city ?? '');
    _billState = TextEditingController(text: _billingAddress.state ?? '');
    _billPostalCode =
        TextEditingController(text: _billingAddress.postalCode ?? '');
  }

  @override
  void dispose() {
    _shipFirstName.dispose();
    _shipLastName.dispose();
    _shipAddress1.dispose();
    _shipAddress2.dispose();
    _shipCity.dispose();
    _shipState.dispose();
    _shipPostalCode.dispose();
    _shipPhone.dispose();
    _shipEmail.dispose();
    _billFirstName.dispose();
    _billLastName.dispose();
    _billAddress1.dispose();
    _billAddress2.dispose();
    _billCity.dispose();
    _billState.dispose();
    _billPostalCode.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Address helpers
  // ---------------------------------------------------------------------------

  void _syncShippingAddress() {
    _shippingAddress = OiAddressData(
      firstName:
          _shipFirstName.text.isEmpty ? null : _shipFirstName.text,
      lastName: _shipLastName.text.isEmpty ? null : _shipLastName.text,
      address1: _shipAddress1.text.isEmpty ? null : _shipAddress1.text,
      address2: _shipAddress2.text.isEmpty ? null : _shipAddress2.text,
      city: _shipCity.text.isEmpty ? null : _shipCity.text,
      state: _shipState.text.isEmpty ? null : _shipState.text,
      postalCode:
          _shipPostalCode.text.isEmpty ? null : _shipPostalCode.text,
      country: _shippingAddress.country,
      phone: _shipPhone.text.isEmpty ? null : _shipPhone.text,
      email: _shipEmail.text.isEmpty ? null : _shipEmail.text,
    );
    widget.onShippingAddressChange?.call(_shippingAddress);
  }

  void _syncBillingAddress() {
    _billingAddress = OiAddressData(
      firstName:
          _billFirstName.text.isEmpty ? null : _billFirstName.text,
      lastName: _billLastName.text.isEmpty ? null : _billLastName.text,
      address1: _billAddress1.text.isEmpty ? null : _billAddress1.text,
      address2: _billAddress2.text.isEmpty ? null : _billAddress2.text,
      city: _billCity.text.isEmpty ? null : _billCity.text,
      state: _billState.text.isEmpty ? null : _billState.text,
      postalCode:
          _billPostalCode.text.isEmpty ? null : _billPostalCode.text,
      country: _billingAddress.country,
    );
    widget.onBillingAddressChange?.call(_billingAddress);
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  bool _validateCurrentStep() {
    final step = widget.steps[_currentStepIndex];
    switch (step) {
      case OiCheckoutStep.address:
        return _validateAddress();
      case OiCheckoutStep.shipping:
        return _selectedShipping != null;
      case OiCheckoutStep.payment:
        return _selectedPayment != null;
      case OiCheckoutStep.review:
        return true;
    }
  }

  bool _validateAddress() {
    _syncShippingAddress();
    if (!_sameBilling) _syncBillingAddress();

    final errors = <String, String?>{};
    if (_shipFirstName.text.isEmpty) {
      errors['shipFirstName'] = 'First name is required';
    }
    if (_shipLastName.text.isEmpty) {
      errors['shipLastName'] = 'Last name is required';
    }
    if (_shipAddress1.text.isEmpty) {
      errors['shipAddress1'] = 'Address is required';
    }
    if (_shipCity.text.isEmpty) {
      errors['shipCity'] = 'City is required';
    }
    if (_shipPostalCode.text.isEmpty) {
      errors['shipPostalCode'] = 'Postal code is required';
    }
    if (_shippingAddress.country == null ||
        _shippingAddress.country!.isEmpty) {
      errors['shipCountry'] = 'Country is required';
    }

    if (!_sameBilling) {
      if (_billFirstName.text.isEmpty) {
        errors['billFirstName'] = 'First name is required';
      }
      if (_billLastName.text.isEmpty) {
        errors['billLastName'] = 'Last name is required';
      }
      if (_billAddress1.text.isEmpty) {
        errors['billAddress1'] = 'Address is required';
      }
      if (_billCity.text.isEmpty) {
        errors['billCity'] = 'City is required';
      }
      if (_billPostalCode.text.isEmpty) {
        errors['billPostalCode'] = 'Postal code is required';
      }
    }

    setState(() {
      _addressErrors
        ..clear()
        ..addAll(errors);
    });
    return errors.isEmpty;
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _goToStep(int index) {
    if (index < 0 || index >= widget.steps.length) return;
    setState(() {
      _currentStepIndex = index;
      _orderError = null;
    });
  }

  void _goNext() {
    if (!_validateCurrentStep()) return;

    setState(() {
      _completedSteps.add(_currentStepIndex);
    });

    if (_currentStepIndex < widget.steps.length - 1) {
      _goToStep(_currentStepIndex + 1);
    }
  }

  void _goPrevious() {
    if (_currentStepIndex > 0) {
      _goToStep(_currentStepIndex - 1);
    }
  }

  Future<void> _handlePlaceOrder() async {
    if (widget.onPlaceOrder == null) return;
    setState(() {
      _isPlacingOrder = true;
      _orderError = null;
    });
    try {
      await widget.onPlaceOrder!();
    } catch (e) {
      if (mounted) {
        setState(() {
          _orderError = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Step label
  // ---------------------------------------------------------------------------

  String _stepLabel(OiCheckoutStep step) {
    switch (step) {
      case OiCheckoutStep.address:
        return 'Address';
      case OiCheckoutStep.shipping:
        return 'Shipping';
      case OiCheckoutStep.payment:
        return 'Payment';
      case OiCheckoutStep.review:
        return 'Review';
    }
  }

  // ---------------------------------------------------------------------------
  // Address step
  // ---------------------------------------------------------------------------

  Widget _buildAddressStep(BuildContext context) {
    final breakpoint = context.breakpoint;
    final sp = context.spacing;

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.md),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const OiLabel.h3('Shipping Address'),
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
            setState(() {
              _shippingAddress = _shippingAddress.copyWith(country: v);
            });
            _syncShippingAddress();
          },
          errorPrefix: 'ship',
          showContactFields: true,
        ),
        OiCheckbox(
          value: _sameBilling,
          label: 'Billing address same as shipping',
          onChanged: (v) {
            setState(() {
              _sameBilling = v;
            });
          },
        ),
        if (!_sameBilling) ...[
          Padding(
            padding: EdgeInsets.only(top: sp.sm),
            child: const OiLabel.h3('Billing Address'),
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
              setState(() {
                _billingAddress = _billingAddress.copyWith(country: v);
              });
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
    TextEditingController? phoneCtrl,
    TextEditingController? emailCtrl,
    required String? selectedCountry,
    required ValueChanged<String?> onCountryChanged,
    required String errorPrefix,
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
                label: 'First Name',
                error: _addressErrors['${errorPrefix}FirstName'],
                onChanged: (_) => _syncShippingAddress(),
              ),
            ),
            SizedBox(width: sp.sm),
            Expanded(
              child: OiTextInput(
                controller: lastNameCtrl,
                label: 'Last Name',
                error: _addressErrors['${errorPrefix}LastName'],
                onChanged: (_) => _syncShippingAddress(),
              ),
            ),
          ],
        ),
        SizedBox(height: sp.sm),
        OiTextInput(
          controller: address1Ctrl,
          label: 'Address',
          error: _addressErrors['${errorPrefix}Address1'],
          onChanged: (_) => _syncShippingAddress(),
        ),
        SizedBox(height: sp.sm),
        OiTextInput(
          controller: address2Ctrl,
          label: 'Apartment, suite, etc. (optional)',
          onChanged: (_) => _syncShippingAddress(),
        ),
        SizedBox(height: sp.sm),
        Row(
          children: [
            Expanded(
              child: OiTextInput(
                controller: cityCtrl,
                label: 'City',
                error: _addressErrors['${errorPrefix}City'],
                onChanged: (_) => _syncShippingAddress(),
              ),
            ),
            SizedBox(width: sp.sm),
            Expanded(
              child: OiTextInput(
                controller: stateCtrl,
                label: 'State / Province',
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
                label: 'Postal Code',
                error: _addressErrors['${errorPrefix}PostalCode'],
                onChanged: (_) => _syncShippingAddress(),
              ),
            ),
            SizedBox(width: sp.sm),
            Expanded(
              child: widget.countries != null
                  ? OiSelect<String>(
                      options: widget.countries!,
                      value: selectedCountry,
                      label: 'Country',
                      error: _addressErrors['${errorPrefix}Country'],
                      placeholder: 'Select country',
                      onChanged: onCountryChanged,
                    )
                  : OiTextInput(
                      label: 'Country',
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
                  label: 'Phone (optional)',
                  onChanged: (_) => _syncShippingAddress(),
                ),
              ),
              if (emailCtrl != null) ...[
                SizedBox(width: sp.sm),
                Expanded(
                  child: OiTextInput(
                    controller: emailCtrl,
                    label: 'Email (optional)',
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

  // ---------------------------------------------------------------------------
  // Shipping step
  // ---------------------------------------------------------------------------

  Widget _buildShippingStep(BuildContext context) {
    final breakpoint = context.breakpoint;
    final sp = context.spacing;
    final colors = context.colors;
    final methods = widget.shippingMethods ?? [];

    if (methods.isEmpty) {
      return const OiLabel.body('No shipping options available.');
    }

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.sm),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const OiLabel.h3('Shipping Method'),
        for (final method in methods)
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedShipping = method;
              });
              widget.onShippingMethodChange?.call(method);
            },
            child: Semantics(
              label: '${method.label} shipping option',
              selected: _selectedShipping?.key == method.key,
              child: Container(
                padding: EdgeInsets.all(sp.md),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedShipping?.key == method.key
                        ? colors.primary.base
                        : colors.border,
                    width: _selectedShipping?.key == method.key ? 2 : 1,
                  ),
                  borderRadius: context.radius.md,
                ),
                child: Row(
                  children: [
                    _RadioDot(
                      selected: _selectedShipping?.key == method.key,
                      color: colors.primary.base,
                    ),
                    SizedBox(width: sp.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OiLabel.bodyStrong(method.label),
                          if (method.description != null)
                            OiLabel.small(method.description!),
                          if (method.estimatedDelivery != null)
                            OiLabel.small(method.estimatedDelivery!),
                        ],
                      ),
                    ),
                    OiLabel.bodyStrong(
                      method.price == 0
                          ? 'Free'
                          : '\$${method.price.toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Payment step
  // ---------------------------------------------------------------------------

  Widget _buildPaymentStep(BuildContext context) {
    final breakpoint = context.breakpoint;
    final sp = context.spacing;
    final colors = context.colors;
    final methods = widget.paymentMethods ?? [];

    if (methods.isEmpty) {
      return const OiLabel.body('No payment options available.');
    }

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.sm),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const OiLabel.h3('Payment Method'),
        for (final method in methods)
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedPayment = method;
              });
              widget.onPaymentMethodChange?.call(method);
            },
            child: Semantics(
              label: '${method.label} payment option',
              selected: _selectedPayment?.key == method.key,
              child: Container(
                padding: EdgeInsets.all(sp.md),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedPayment?.key == method.key
                        ? colors.primary.base
                        : colors.border,
                    width: _selectedPayment?.key == method.key ? 2 : 1,
                  ),
                  borderRadius: context.radius.md,
                ),
                child: Row(
                  children: [
                    _RadioDot(
                      selected: _selectedPayment?.key == method.key,
                      color: colors.primary.base,
                    ),
                    SizedBox(width: sp.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OiLabel.bodyStrong(method.label),
                          if (method.description != null)
                            OiLabel.small(method.description!),
                        ],
                      ),
                    ),
                    if (method.isDefault) const OiBadge.soft(label: 'Default'),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Review step
  // ---------------------------------------------------------------------------

  Widget _buildReviewStep(BuildContext context) {
    final breakpoint = context.breakpoint;
    final sp = context.spacing;
    final colors = context.colors;

    Widget editLink(String text, OiCheckoutStep target) {
      final targetIndex = widget.steps.indexOf(target);
      if (targetIndex < 0) return const SizedBox.shrink();
      return GestureDetector(
        onTap: _isPlacingOrder ? null : () => _goToStep(targetIndex),
        child: Semantics(
          label: 'Edit $text',
          button: true,
          child: OiLabel.small(
            'Edit',
            color: colors.primary.base,
          ),
        ),
      );
    }

    Widget sectionHeader(String title, OiCheckoutStep target) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OiLabel.bodyStrong(title),
          editLink(title, target),
        ],
      );
    }

    String formatAddress(OiAddressData addr) {
      final parts = <String>[
        if (addr.firstName != null || addr.lastName != null)
          [addr.firstName ?? '', addr.lastName ?? ''].join(' ').trim(),
        if (addr.address1 != null) addr.address1!,
        if (addr.address2 != null && addr.address2!.isNotEmpty) addr.address2!,
        [
          addr.city ?? '',
          addr.state ?? '',
          addr.postalCode ?? '',
        ].where((s) => s.isNotEmpty).join(', '),
        if (addr.country != null) addr.country!,
      ];
      return parts.where((s) => s.isNotEmpty).join('\n');
    }

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.md),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const OiLabel.h3('Review Your Order'),

        // Shipping address.
        if (widget.steps.contains(OiCheckoutStep.address)) ...[
          sectionHeader('Shipping Address', OiCheckoutStep.address),
          OiLabel.body(formatAddress(_shippingAddress)),
          if (!_sameBilling) ...[
            SizedBox(height: sp.xs),
            sectionHeader('Billing Address', OiCheckoutStep.address),
            OiLabel.body(formatAddress(_billingAddress)),
          ],
          const OiDivider(),
        ],

        // Shipping method.
        if (widget.steps.contains(OiCheckoutStep.shipping) &&
            _selectedShipping != null) ...[
          sectionHeader('Shipping Method', OiCheckoutStep.shipping),
          OiLabel.body(_selectedShipping!.label),
          if (_selectedShipping!.estimatedDelivery != null)
            OiLabel.small(_selectedShipping!.estimatedDelivery!),
          const OiDivider(),
        ],

        // Payment method.
        if (widget.steps.contains(OiCheckoutStep.payment) &&
            _selectedPayment != null) ...[
          sectionHeader('Payment Method', OiCheckoutStep.payment),
          OiLabel.body(_selectedPayment!.label),
          if (_selectedPayment!.description != null)
            OiLabel.small(_selectedPayment!.description!),
          const OiDivider(),
        ],

        // Error message.
        if (_orderError != null)
          Container(
            padding: EdgeInsets.all(sp.sm),
            decoration: BoxDecoration(
              color: colors.error.muted,
              borderRadius: context.radius.sm,
            ),
            child: OiLabel.body(_orderError!, color: colors.error.base),
          ),

        // Place order button.
        OiButton.primary(
          label: widget.placeOrderLabel ?? 'Place Order',
          onTap: _isPlacingOrder ? null : _handlePlaceOrder,
          loading: _isPlacingOrder,
          fullWidth: true,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step content router
  // ---------------------------------------------------------------------------

  Widget _buildStepContent(BuildContext context) {
    final step = widget.steps[_currentStepIndex];
    switch (step) {
      case OiCheckoutStep.address:
        return _buildAddressStep(context);
      case OiCheckoutStep.shipping:
        return _buildShippingStep(context);
      case OiCheckoutStep.payment:
        return _buildPaymentStep(context);
      case OiCheckoutStep.review:
        return _buildReviewStep(context);
    }
  }

  // ---------------------------------------------------------------------------
  // Navigation bar
  // ---------------------------------------------------------------------------

  Widget _buildNavBar(BuildContext context) {
    final isFirst = _currentStepIndex == 0;
    final isReview =
        widget.steps[_currentStepIndex] == OiCheckoutStep.review;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.onCancel != null)
              OiButton.ghost(
                label: 'Cancel',
                onTap: widget.onCancel,
              ),
            if (!isFirst)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: OiButton.outline(
                  label: 'Previous',
                  onTap: _isPlacingOrder ? null : _goPrevious,
                ),
              ),
          ],
        ),
        if (!isReview)
          OiButton.primary(
            label: 'Next',
            onTap: _goNext,
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Layouts
  // ---------------------------------------------------------------------------

  Widget _buildDesktopLayout(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: OiColumn(
            breakpoint: breakpoint,
            gap: OiResponsive(sp.md),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OiStepper(
                totalSteps: widget.steps.length,
                currentStep: _currentStepIndex,
                stepLabels: widget.steps.map(_stepLabel).toList(),
                completedSteps: _completedSteps,
                onStepTap: _goToStep,
              ),
              _buildStepContent(context),
              _buildNavBar(context),
            ],
          ),
        ),
        if (widget.showSummary) ...[
          SizedBox(width: sp.lg),
          SizedBox(
            width: 320,
            child: OiOrderSummary(
              summary: widget.summary,
              items: widget.items,
              label: 'Order summary',
              currencyCode: widget.currencyCode,
              showItems: true,
              expandedByDefault: true,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.md),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showSummary)
          OiAccordion(
            sections: [
              OiAccordionSection(
                title: 'Order Summary',
                content: OiOrderSummary(
                  summary: widget.summary,
                  items: widget.items,
                  label: 'Order summary',
                  currencyCode: widget.currencyCode,
                  showItems: true,
                ),
              ),
            ],
          ),
        OiStepper(
          totalSteps: widget.steps.length,
          currentStep: _currentStepIndex,
          stepLabels: widget.steps.map(_stepLabel).toList(),
          completedSteps: _completedSteps,
          onStepTap: _goToStep,
          style: OiStepperStyle.compact,
        ),
        _buildStepContent(context),
        _buildNavBar(context),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final breakpoint = context.breakpoint;
    final isDesktop = breakpoint.compareTo(OiBreakpoint.expanded) >= 0;

    if (widget.items.isEmpty) {
      return Semantics(
        label: widget.label,
        child: const Center(
          child: OiLabel.body('Your cart is empty.'),
        ),
      );
    }

    return Semantics(
      label: widget.label,
      child: isDesktop
          ? _buildDesktopLayout(context)
          : _buildMobileLayout(context),
    );
  }
}

// ── Private helper widgets ──────────────────────────────────────────────────

/// A small radio-button dot indicator.
class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected, required this.color});

  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? color : colors.border,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
            )
          : null,
    );
  }
}
