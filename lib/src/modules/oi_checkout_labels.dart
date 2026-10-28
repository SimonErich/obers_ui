import 'package:obers_ui/src/composites/forms/oi_stepper.dart';
import 'package:obers_ui/src/composites/shop/oi_order_summary.dart';
import 'package:obers_ui/src/modules/oi_checkout.dart';

/// The texts of an [OiCheckout], in English by default; pass translations to
/// localize the checkout.
///
/// {@category Modules}
class OiCheckoutLabels {
  /// Creates an [OiCheckoutLabels].
  const OiCheckoutLabels({
    this.addressStep = 'Address',
    this.shippingStep = 'Shipping',
    this.paymentStep = 'Payment',
    this.reviewStep = 'Review',
    this.stepOf = OiStepper.englishProgressLabel,
    this.cancel = 'Cancel',
    this.previous = 'Previous',
    this.next = 'Next',
    this.placeOrder = 'Place Order',
    this.emptyCart = 'Your cart is empty.',
    this.orderSummaryTitle = 'Order Summary',
    this.orderSummary = 'Order summary',
    this.shippingAddress = 'Shipping Address',
    this.billingAddress = 'Billing Address',
    this.sameBilling = 'Billing address same as shipping',
    this.firstName = 'First Name',
    this.lastName = 'Last Name',
    this.address = 'Address',
    this.address2 = 'Apartment, suite, etc. (optional)',
    this.city = 'City',
    this.state = 'State / Province',
    this.postalCode = 'Postal Code',
    this.country = 'Country',
    this.selectCountry = 'Select country',
    this.phone = 'Phone (optional)',
    this.email = 'Email (optional)',
    this.firstNameRequired = 'First name is required',
    this.lastNameRequired = 'Last name is required',
    this.addressRequired = 'Address is required',
    this.cityRequired = 'City is required',
    this.postalCodeRequired = 'Postal code is required',
    this.countryRequired = 'Country is required',
    this.shippingMethod = 'Shipping Method',
    this.noShippingOptions = 'No shipping options available.',
    this.shippingOption = englishShippingOption,
    this.free = 'Free',
    this.paymentMethod = 'Payment Method',
    this.noPaymentOptions = 'No payment options available.',
    this.paymentOption = englishPaymentOption,
    this.defaultPayment = 'Default',
    this.reviewTitle = 'Review Your Order',
    this.edit = 'Edit',
    this.editSection = englishEditSection,
    this.summary = const OiOrderSummaryLabels(),
  });

  /// "Express shipping option": the default [shippingOption].
  static String englishShippingOption(String method) =>
      '$method shipping option';

  /// "Card payment option": the default [paymentOption].
  static String englishPaymentOption(String method) => '$method payment option';

  /// "Edit Shipping Address": the default [editSection].
  static String englishEditSection(String section) => 'Edit $section';

  /// Name of the address step.
  final String addressStep;

  /// Name of the shipping step.
  final String shippingStep;

  /// Name of the payment step.
  final String paymentStep;

  /// Name of the review step.
  final String reviewStep;

  /// "Step 2 of 4" for the one-based step of the total, read by screen
  /// readers on the step indicator.
  final String Function(int step, int total) stepOf;

  /// Label of the cancel button.
  final String cancel;

  /// Label of the button that goes back a step.
  final String previous;

  /// Label of the button that goes on to the next step.
  final String next;

  /// Label of the button that places the order, unless
  /// [OiCheckout.placeOrderLabel] is set.
  final String placeOrder;

  /// Shown in place of the checkout while the cart is empty.
  final String emptyCart;

  /// Title of the collapsible order summary on narrow screens.
  final String orderSummaryTitle;

  /// Screen-reader label of the order summary.
  final String orderSummary;

  /// Heading of the shipping address form and review section.
  final String shippingAddress;

  /// Heading of the billing address form and review section.
  final String billingAddress;

  /// Label of the switch that uses the shipping address for billing.
  final String sameBilling;

  /// Label of the first name input.
  final String firstName;

  /// Label of the last name input.
  final String lastName;

  /// Label of the first address line input.
  final String address;

  /// Label of the second address line input.
  final String address2;

  /// Label of the city input.
  final String city;

  /// Label of the state / province input.
  final String state;

  /// Label of the postal code input.
  final String postalCode;

  /// Label of the country input.
  final String country;

  /// Placeholder of the country select.
  final String selectCountry;

  /// Label of the phone input.
  final String phone;

  /// Label of the email input.
  final String email;

  /// Error shown when the first name is empty.
  final String firstNameRequired;

  /// Error shown when the last name is empty.
  final String lastNameRequired;

  /// Error shown when the first address line is empty.
  final String addressRequired;

  /// Error shown when the city is empty.
  final String cityRequired;

  /// Error shown when the postal code is empty.
  final String postalCodeRequired;

  /// Error shown when no country is given.
  final String countryRequired;

  /// Heading of the shipping step and review section.
  final String shippingMethod;

  /// Shown when there are no shipping methods.
  final String noShippingOptions;

  /// Screen-reader label of the named shipping method.
  final String Function(String method) shippingOption;

  /// Shown in place of the price of a free shipping method.
  final String free;

  /// Heading of the payment step and review section.
  final String paymentMethod;

  /// Shown when there are no payment methods.
  final String noPaymentOptions;

  /// Screen-reader label of the named payment method.
  final String Function(String method) paymentOption;

  /// Marker shown on the default payment method.
  final String defaultPayment;

  /// Heading of the review step.
  final String reviewTitle;

  /// Label of the links that go back to a step from the review.
  final String edit;

  /// Screen-reader label of the edit link of the named review section.
  final String Function(String section) editSection;

  /// The texts of the order summary.
  final OiOrderSummaryLabels summary;
}
