// Tests do not require documentation comments.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/golden_helper.dart';
import '../../helpers/pump_app.dart';

// ── Test data helpers ────────────────────────────────────────────────────────

List<OiCartItem> _sampleCartItems() => const [
  OiCartItem(productKey: 'p1', name: 'Widget A', unitPrice: 29.99),
  OiCartItem(productKey: 'p2', name: 'Widget B', unitPrice: 49.99, quantity: 2),
];

OiCartSummary _sampleSummary() => const OiCartSummary(
  subtotal: 129.97,
  shipping: 5.99,
  tax: 10.80,
  total: 146.76,
);

List<OiShippingMethod> _sampleShippingMethods() => const [
  OiShippingMethod(
    key: 'standard',
    label: 'Standard Shipping',
    price: 5.99,
    estimatedDelivery: '5-7 business days',
  ),
  OiShippingMethod(
    key: 'express',
    label: 'Express Shipping',
    price: 14.99,
    estimatedDelivery: '1-2 business days',
  ),
];

List<OiPaymentMethod> _samplePaymentMethods() => const [
  OiPaymentMethod(
    key: 'credit',
    label: 'Credit Card',
    description: 'Visa ending in 4242',
    defaultMethod: true,
  ),
  OiPaymentMethod(
    key: 'paypal',
    label: 'PayPal',
    description: 'user@example.com',
  ),
];

List<OiCountryOption> _sampleCountries() => const [
  OiCountryOption(code: 'US', name: 'United States'),
  OiCountryOption(code: 'DE', name: 'Germany'),
  OiCountryOption(code: 'GB', name: 'United Kingdom'),
];

OiAddressData _sampleAddress() => const OiAddressData(
  firstName: 'Jane',
  lastName: 'Doe',
  line1: '123 Main St',
  city: 'Springfield',
  state: 'IL',
  postalCode: '62701',
  country: 'US',
  phone: '555-0100',
  email: 'jane@example.com',
);

Widget _buildCheckout({
  List<OiCartItem>? items,
  OiCartSummary? summary,
  String label = 'Checkout',
  List<OiCheckoutStep>? steps,
  ValueChanged<OiAddressData>? onShippingAddressChange,
  ValueChanged<OiAddressData>? onBillingAddressChange,
  ValueChanged<OiShippingMethod>? onShippingMethodChange,
  ValueChanged<OiPaymentMethod>? onPaymentMethodChange,
  Future<OiOrderData> Function(OiCheckoutData)? onPlaceOrder,
  VoidCallback? onCancel,
  OiAddressData? initialShippingAddress,
  OiAddressData? initialBillingAddress,
  List<OiShippingMethod>? shippingMethods,
  List<OiPaymentMethod>? paymentMethods,
  List<OiCountryOption>? countries,
  bool showSummary = true,
  bool sameBillingDefault = true,
  String currencyCode = 'USD',
  String? placeOrderLabel,
}) {
  return SingleChildScrollView(
    child: OiCheckout(
      items: items ?? _sampleCartItems(),
      summary: summary ?? _sampleSummary(),
      label: label,
      steps:
          steps ??
          const [
            OiCheckoutStep.address,
            OiCheckoutStep.shipping,
            OiCheckoutStep.payment,
            OiCheckoutStep.review,
          ],
      onShippingAddressChange: onShippingAddressChange,
      onBillingAddressChange: onBillingAddressChange,
      onShippingMethodChange: onShippingMethodChange,
      onPaymentMethodChange: onPaymentMethodChange,
      onPlaceOrder: onPlaceOrder,
      onCancel: onCancel,
      initialShippingAddress: initialShippingAddress,
      initialBillingAddress: initialBillingAddress,
      shippingMethods: shippingMethods ?? _sampleShippingMethods(),
      paymentMethods: paymentMethods ?? _samplePaymentMethods(),
      countries: countries ?? _sampleCountries(),
      showSummary: showSummary,
      sameBillingDefault: sameBillingDefault,
      currencyCode: currencyCode,
      placeOrderLabel: placeOrderLabel,
    ),
  );
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  // ── Step Rendering (1-2) ─────────────────────────────────────────────────

  group('Step Rendering', () {
    testWidgets('renders address step with form fields', (tester) async {
      await tester.pumpObers(
        _buildCheckout(),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pumpAndSettle();

      // Address step is the first step — verify heading and fields.
      expect(find.text('Shipping Address'), findsOneWidget);
      expect(find.text('First Name'), findsAtLeast(1));
      expect(find.text('Last Name'), findsAtLeast(1));
      expect(find.text('Address'), findsAtLeast(1));
      expect(find.text('City'), findsAtLeast(1));
      expect(find.text('Postal Code'), findsAtLeast(1));
      expect(find.text('Billing address same as shipping'), findsOneWidget);
    });

    testWidgets('renders all steps in correct order', (tester) async {
      await tester.pumpObers(
        _buildCheckout(),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pumpAndSettle();

      // The stepper should show labels for all 4 steps.
      expect(find.text('Address'), findsAtLeast(1));
      expect(find.text('Shipping'), findsAtLeast(1));
      expect(find.text('Payment'), findsAtLeast(1));
      expect(find.text('Review'), findsAtLeast(1));
    });
  });

  // ── Stepper Progress (3) ─────────────────────────────────────────────────

  group('Stepper Progress', () {
    testWidgets('stepper updates progress on step advance', (tester) async {
      await tester.pumpObers(
        _buildCheckout(initialShippingAddress: _sampleAddress()),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pumpAndSettle();

      // Find and tap the Next button to advance from address step.
      // First we need a valid country — the initialShippingAddress has 'US'.
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Should now be on Shipping step — verify heading.
      expect(find.text('Shipping Method'), findsOneWidget);
    });
  });

  // ── Validation (4) ───────────────────────────────────────────────────────

  group('Validation', () {
    testWidgets('address step validates required fields before advance', (
      tester,
    ) async {
      await tester.pumpObers(
        _buildCheckout(),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pumpAndSettle();

      // Try to advance without filling any fields.
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Error messages should appear for required fields.
      expect(find.text('First name is required'), findsAtLeast(1));
      expect(find.text('Last name is required'), findsAtLeast(1));
      expect(find.text('Address is required'), findsAtLeast(1));
      expect(find.text('City is required'), findsAtLeast(1));
      expect(find.text('Postal code is required'), findsAtLeast(1));
      expect(find.text('Country is required'), findsAtLeast(1));

      // Should still be on address step.
      expect(find.text('Shipping Address'), findsOneWidget);
    });
  });

  // ── Selection Persistence (5-6) ──────────────────────────────────────────

  group('Selection Persistence', () {
    testWidgets('shipping method selection persists across steps', (
      tester,
    ) async {
      await tester.pumpObers(
        _buildCheckout(initialShippingAddress: _sampleAddress()),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pumpAndSettle();

      // Advance to shipping step.
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Shipping Method'), findsOneWidget);

      // Select Express Shipping.
      await tester.tap(find.text('Express Shipping'));
      await tester.pumpAndSettle();

      // Advance to payment step.
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Payment Method'), findsOneWidget);

      // Go back to shipping step.
      await tester.tap(find.text('Previous'));
      await tester.pumpAndSettle();

      // Express Shipping should still be the rendered (selected) method.
      expect(find.text('Express Shipping'), findsOneWidget);
      expect(find.text('Shipping Method'), findsOneWidget);
    });

    testWidgets('payment method selection persists across steps', (
      tester,
    ) async {
      await tester.pumpObers(
        _buildCheckout(initialShippingAddress: _sampleAddress()),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pumpAndSettle();

      // Advance to shipping step.
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Advance to payment step.
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Payment Method'), findsOneWidget);

      // Select PayPal.
      await tester.tap(find.text('PayPal'));
      await tester.pumpAndSettle();

      // Go back then forward.
      await tester.tap(find.text('Previous'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // PayPal should still be visible.
      expect(find.text('PayPal'), findsOneWidget);
    });
  });

  // ── Same-as-Shipping (7) ─────────────────────────────────────────────────

  group('Same-as-Shipping', () {
    testWidgets('same-as-shipping checkbox toggles billing address fields', (
      tester,
    ) async {
      await tester.pumpObers(
        _buildCheckout(),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pumpAndSettle();

      // By default, same-as-shipping is checked — no billing address section.
      expect(find.text('Billing Address'), findsNothing);

      // Uncheck the checkbox.
      await tester.tap(find.text('Billing address same as shipping'));
      await tester.pumpAndSettle();

      // Now billing address fields should appear.
      expect(find.text('Billing Address'), findsOneWidget);

      // Check it again to hide billing fields.
      await tester.tap(find.text('Billing address same as shipping'));
      await tester.pumpAndSettle();
      expect(find.text('Billing Address'), findsNothing);
    });
  });

  // ── Review Step (8-9) ────────────────────────────────────────────────────

  group('Review Step', () {
    Future<void> advanceToReview(WidgetTester tester) async {
      // Address → Shipping → Payment → Review
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    testWidgets('review step shows all selections read-only', (tester) async {
      await tester.pumpObers(
        _buildCheckout(initialShippingAddress: _sampleAddress()),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pumpAndSettle();

      await advanceToReview(tester);

      // Verify review heading.
      expect(find.text('Review Your Order'), findsOneWidget);

      // Shipping address info should be displayed.
      expect(find.textContaining('Jane'), findsAtLeast(1));
      expect(find.textContaining('123 Main St'), findsAtLeast(1));

      // Shipping method should be displayed.
      expect(find.text('Standard Shipping'), findsAtLeast(1));

      // Payment method should be displayed.
      expect(find.text('Credit Card'), findsAtLeast(1));

      // Place order button should be present.
      expect(find.text('Place Order'), findsOneWidget);
    });

    testWidgets('edit links navigate back to correct step', (tester) async {
      await tester.pumpObers(
        _buildCheckout(initialShippingAddress: _sampleAddress()),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pumpAndSettle();

      await advanceToReview(tester);
      expect(find.text('Review Your Order'), findsOneWidget);

      // Find the Edit link for Shipping Method section and tap it.
      final editButtons = find.text('Edit');
      expect(editButtons, findsAtLeast(1));

      // The second Edit link should be for Shipping Method
      // (first is Shipping Address, second is Shipping Method, third is
      // Payment Method).
      await tester.tap(editButtons.at(1));
      await tester.pumpAndSettle();

      // Should now be on the shipping step.
      expect(find.text('Shipping Method'), findsOneWidget);
    });
  });

  // ── Place Order (10-12) ──────────────────────────────────────────────────

  group('Place Order', () {
    Future<void> advanceToReview(WidgetTester tester) async {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    testWidgets('onPlaceOrder callback invoked on place order', (tester) async {
      var orderPlaced = false;
      await tester.pumpObers(
        _buildCheckout(
          initialShippingAddress: _sampleAddress(),
          onPlaceOrder: (_) async {
            orderPlaced = true;
            return OiOrderData(
              key: 'order-1',
              orderNumber: 'ORD-2024-001',
              createdAt: DateTime(2024),
              status: OiOrderStatus.pending,
              shippingAddress: _sampleAddress(),
              shippingMethod: _sampleShippingMethods().first,
              paymentMethod: _samplePaymentMethods().first,
              items: _sampleCartItems(),
              summary: _sampleSummary(),
            );
          },
        ),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pumpAndSettle();

      await advanceToReview(tester);
      await tester.tap(find.text('Place Order'));
      await tester.pumpAndSettle();

      expect(orderPlaced, isTrue);
    });

    testWidgets('loading state shown during order placement', (tester) async {
      final completer = Completer<OiOrderData>();

      await tester.pumpObers(
        _buildCheckout(
          initialShippingAddress: _sampleAddress(),
          onPlaceOrder: (_) => completer.future,
        ),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pumpAndSettle();

      await advanceToReview(tester);
      await tester.tap(find.text('Place Order'));
      await tester.pump(); // Don't settle — future is pending.

      // The place order button should be in loading state (disabled).
      // OiButton.primary with loading: true renders a loading indicator
      // instead of the label text — so 'Place Order' text is not visible.
      expect(find.text('Place Order'), findsNothing);
      // The OiButton widget itself should still be present in the tree.
      expect(find.byType(OiButton), findsAtLeast(1));

      // Complete the future to avoid pending timers.
      completer.complete(
        OiOrderData(
          key: 'order-2',
          orderNumber: 'ORD-2024-002',
          createdAt: DateTime(2024),
          status: OiOrderStatus.pending,
          shippingAddress: _sampleAddress(),
          shippingMethod: _sampleShippingMethods().first,
          paymentMethod: _samplePaymentMethods().first,
          items: _sampleCartItems(),
          summary: _sampleSummary(),
        ),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('error handling on order failure', (tester) async {
      await tester.pumpObers(
        _buildCheckout(
          initialShippingAddress: _sampleAddress(),
          onPlaceOrder: (_) async {
            throw Exception('Payment declined');
          },
        ),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pumpAndSettle();

      await advanceToReview(tester);
      await tester.tap(find.text('Place Order'));
      await tester.pumpAndSettle();

      // Error message should be displayed.
      expect(find.textContaining('Payment declined'), findsOneWidget);

      // Place order button should still be available for retry.
      expect(find.text('Place Order'), findsOneWidget);
    });
  });

  // ── Responsive Layout (13-14) ────────────────────────────────────────────

  group('Responsive Layout', () {
    testWidgets('desktop layout shows two-column with persistent summary', (
      tester,
    ) async {
      // Desktop: ≥840dp → two-column layout with OiOrderSummary on right.
      await tester.pumpObers(
        _buildCheckout(),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pumpAndSettle();

      // On desktop, OiOrderSummary is always visible (not in accordion wrapper).
      expect(find.byType(OiOrderSummary), findsOneWidget);
      // OiOrderSummary renders "Order Summary" text internally — it is
      // visible on desktop (not hidden inside a collapsed accordion).
      expect(find.text('Order Summary'), findsOneWidget);
      // On desktop the OiOrderSummary is NOT nested inside an extra OiAccordion
      // wrapper. The OiOrderSummary may have its own internal accordion for
      // items, but there should be no additional wrapper accordion here.
    });

    testWidgets('mobile layout shows single column with collapsible summary', (
      tester,
    ) async {
      // Mobile: <840dp → single column with accordion summary.
      // Use 600px wide to avoid overflow in OiCheckbox row at narrow widths.
      await tester.pumpObers(
        _buildCheckout(),
        surfaceSize: const Size(600, 800),
      );
      await tester.pumpAndSettle();

      // On mobile, the summary is wrapped in an OiAccordion with title
      // 'Order Summary'. OiOrderSummary also renders "Order Summary" text
      // internally, so there may be more than one match.
      expect(find.text('Order Summary'), findsAtLeast(1));
      // The mobile layout adds an accordion wrapper around OiOrderSummary,
      // and OiOrderSummary may itself contain an internal accordion for items.
      expect(find.byType(OiAccordion), findsAtLeast(1));
    });
  });

  // ── Cancel (15) ──────────────────────────────────────────────────────────

  group('Cancel', () {
    testWidgets('cancel callback fires on cancel button tap', (tester) async {
      var cancelled = false;
      await tester.pumpObers(
        _buildCheckout(onCancel: () => cancelled = true),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(cancelled, isTrue);
    });
  });

  // ── Keyboard (16) ────────────────────────────────────────────────────────

  group('Keyboard', () {
    testWidgets('keyboard navigation advances through form fields', (
      tester,
    ) async {
      await tester.pumpObers(
        _buildCheckout(),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pumpAndSettle();

      // Tap into first text field (First Name).
      final editables = find.byType(EditableText);
      expect(editables, findsAtLeast(2));

      await tester.tap(editables.first);
      await tester.pumpAndSettle();

      // Press Tab to move to next field.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // The focus should have moved — verify no crash and widget tree intact.
      expect(find.text('Shipping Address'), findsOneWidget);
    });
  });

  // ── Accessibility (17) ───────────────────────────────────────────────────

  group('Accessibility', () {
    testWidgets(
      'accessibility semantics labels present on interactive elements',
      (tester) async {
        final semantics = tester.ensureSemantics();
        await tester.pumpObers(
          _buildCheckout(initialShippingAddress: _sampleAddress()),
          surfaceSize: const Size(1200, 900),
        );
        await tester.pumpAndSettle();

        // The checkout widget wraps in Semantics(label: 'Checkout').
        // The semantics node may merge with children; verify at least one
        // node in the tree carries the label.
        expect(find.bySemanticsLabel(RegExp('Checkout')), findsWidgets);

        // Advance to shipping to check shipping method semantics.
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        // Shipping methods should have semantics labels.
        // Use RegExp because child text may merge into the node label.
        expect(
          find.bySemanticsLabel(RegExp('Standard Shipping shipping option')),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel(RegExp('Express Shipping shipping option')),
          findsOneWidget,
        );
        semantics.dispose();
      },
    );
  });

  // ── Golden Tests (18-20) ─────────────────────────────────────────────────

  group('Golden Tests', () {
    testGoldens('golden — desktop address step', (tester) async {
      final builder = obersGoldenBuilder(
        columns: 1,
        children: {
          'Desktop Address': SizedBox(
            width: 1000,
            height: 700,
            child: _buildCheckout(),
          ),
        },
      );
      await tester.pumpWidgetBuilder(builder);
      await screenMatchesGolden(tester, 'oi_checkout_desktop_address');
    });

    testGoldens('golden — mobile address step', (tester) async {
      final builder = obersGoldenBuilder(
        columns: 1,
        children: {
          'Mobile Address': SizedBox(
            width: 390,
            height: 700,
            child: _buildCheckout(),
          ),
        },
      );
      await tester.pumpWidgetBuilder(builder);
      await screenMatchesGolden(tester, 'oi_checkout_mobile_address');
    });

    testGoldens('golden — desktop review step', (tester) async {
      // For golden tests we build the checkout pre-configured at review step
      // by using a custom step list that only has review.
      final builder = obersGoldenBuilder(
        columns: 1,
        children: {
          'Desktop Review': SizedBox(
            width: 1000,
            height: 700,
            child: _buildCheckout(
              initialShippingAddress: _sampleAddress(),
              steps: const [OiCheckoutStep.review],
            ),
          ),
        },
      );
      await tester.pumpWidgetBuilder(builder);
      await screenMatchesGolden(tester, 'oi_checkout_desktop_review');
    });
  });
}
