import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/inputs/oi_checkbox.dart';
import 'package:obers_ui/src/components/inputs/oi_select.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/components/navigation/oi_accordion.dart';
import 'package:obers_ui/src/components/shop/oi_payment_option.dart';
import 'package:obers_ui/src/components/shop/oi_shipping_option.dart';
import 'package:obers_ui/src/composites/forms/oi_stepper.dart';
import 'package:obers_ui/src/composites/shop/oi_order_summary.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_address_data.dart';
import 'package:obers_ui/src/models/oi_cart_item.dart';
import 'package:obers_ui/src/models/oi_cart_summary.dart';
import 'package:obers_ui/src/models/oi_checkout_data.dart';
import 'package:obers_ui/src/models/oi_country_option.dart';
import 'package:obers_ui/src/models/oi_order_data.dart';
import 'package:obers_ui/src/models/oi_payment_method.dart';
import 'package:obers_ui/src/models/oi_shipping_method.dart';
import 'package:obers_ui/src/primitives/display/oi_divider.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';

part 'oi_checkout/oi_checkout_address.part.dart';
part 'oi_checkout/oi_checkout_layout.part.dart';
part 'oi_checkout/oi_checkout_steps.part.dart';

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
/// Coverage: REQ-0014, REQ-0067
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

  /// Called when the user places the order. Receives the aggregated
  /// [OiCheckoutData] and should return the completed [OiOrderData] or
  /// throw on failure.
  final Future<OiOrderData> Function(OiCheckoutData checkoutData)? onPlaceOrder;

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
  ///
  /// When provided, the country field renders as an [OiSelect] dropdown
  /// populated from these options.
  final List<OiCountryOption>? countries;

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

  // ── setState helpers (callable from extensions) ───────────────────────────

  void _setAddressErrors(Map<String, String?> errors) {
    setState(() {
      _addressErrors
        ..clear()
        ..addAll(errors);
    });
  }

  void _setSameBilling({required bool sameBilling}) =>
      setState(() => _sameBilling = sameBilling);

  void _setShippingCountry(String? country) => setState(
    () => _shippingAddress = _shippingAddress.copyWith(country: country),
  );

  void _setBillingCountry(String? country) => setState(
    () => _billingAddress = _billingAddress.copyWith(country: country),
  );

  void _setSelectedShipping(OiShippingMethod method) =>
      setState(() => _selectedShipping = method);

  void _setSelectedPayment(OiPaymentMethod method) =>
      setState(() => _selectedPayment = method);

  // ── Lifecycle ─────────────────────────────────────────────────────────────

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
          widget.paymentMethods!.where((p) => p.defaultMethod).firstOrNull ??
          widget.paymentMethods!.first;
    }

    _shipFirstName = TextEditingController(
      text: _shippingAddress.firstName ?? '',
    );
    _shipLastName = TextEditingController(
      text: _shippingAddress.lastName ?? '',
    );
    _shipAddress1 = TextEditingController(text: _shippingAddress.line1 ?? '');
    _shipAddress2 = TextEditingController(text: _shippingAddress.line2 ?? '');
    _shipCity = TextEditingController(text: _shippingAddress.city ?? '');
    _shipState = TextEditingController(text: _shippingAddress.state ?? '');
    _shipPostalCode = TextEditingController(
      text: _shippingAddress.postalCode ?? '',
    );
    _shipPhone = TextEditingController(text: _shippingAddress.phone ?? '');
    _shipEmail = TextEditingController(text: _shippingAddress.email ?? '');

    _billFirstName = TextEditingController(
      text: _billingAddress.firstName ?? '',
    );
    _billLastName = TextEditingController(text: _billingAddress.lastName ?? '');
    _billAddress1 = TextEditingController(text: _billingAddress.line1 ?? '');
    _billAddress2 = TextEditingController(text: _billingAddress.line2 ?? '');
    _billCity = TextEditingController(text: _billingAddress.city ?? '');
    _billState = TextEditingController(text: _billingAddress.state ?? '');
    _billPostalCode = TextEditingController(
      text: _billingAddress.postalCode ?? '',
    );
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

  // ── Validation ────────────────────────────────────────────────────────────

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

  // ── Navigation ────────────────────────────────────────────────────────────

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
    if (_selectedShipping == null || _selectedPayment == null) return;

    setState(() {
      _isPlacingOrder = true;
      _orderError = null;
    });
    try {
      final billingAddr = _sameBilling ? _shippingAddress : _billingAddress;
      final checkoutData = OiCheckoutData(
        shippingAddress: _shippingAddress,
        billingAddress: billingAddr,
        shippingMethod: _selectedShipping!,
        paymentMethod: _selectedPayment!,
      );
      await widget.onPlaceOrder!(checkoutData);
    } on Exception catch (e) {
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final breakpoint = context.breakpoint;
    final isDesktop = breakpoint.compareTo(OiBreakpoint.expanded) >= 0;

    if (widget.items.isEmpty) {
      return Semantics(
        label: widget.label,
        child: const Center(child: OiLabel.body('Your cart is empty.')),
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
