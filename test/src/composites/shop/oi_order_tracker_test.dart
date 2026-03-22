// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/shop/oi_order_status_badge.dart';
import 'package:obers_ui/src/composites/forms/oi_stepper.dart';
import 'package:obers_ui/src/composites/shop/oi_order_tracker.dart';
import 'package:obers_ui/src/composites/scheduling/oi_timeline.dart';
import 'package:obers_ui/src/models/oi_address_data.dart';
import 'package:obers_ui/src/models/oi_cart_item.dart';
import 'package:obers_ui/src/models/oi_cart_summary.dart';
import 'package:obers_ui/src/models/oi_order_data.dart';
import 'package:obers_ui/src/models/oi_payment_method.dart';
import 'package:obers_ui/src/models/oi_shipping_method.dart';

import '../../../helpers/pump_app.dart';

// ── Test data ────────────────────────────────────────────────────────────────

List<OiOrderEvent> _sampleTimeline() => [
  OiOrderEvent(
    timestamp: DateTime(2024, 1, 1, 10),
    title: 'Order Placed',
    status: OiOrderStatus.pending,
    description: 'Your order has been received.',
  ),
  OiOrderEvent(
    timestamp: DateTime(2024, 1, 1, 12),
    title: 'Order Confirmed',
    status: OiOrderStatus.confirmed,
  ),
  OiOrderEvent(
    timestamp: DateTime(2024, 1, 2, 9),
    title: 'Processing',
    status: OiOrderStatus.processing,
    description: 'Your order is being prepared.',
  ),
];

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('OiOrderTracker', () {
    testWidgets('renders stepper with 5 status steps', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiOrderTracker(
            currentStatus: OiOrderStatus.pending,
            label: 'Order tracker',
          ),
        ),
        surfaceSize: const Size(800, 400),
      );
      await tester.pumpAndSettle();

      final stepper = tester.widget<OiStepper>(find.byType(OiStepper));
      expect(stepper.totalSteps, 5);
    });

    testWidgets('current status step is highlighted', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiOrderTracker(
            currentStatus: OiOrderStatus.processing,
            label: 'Order tracker',
          ),
        ),
        surfaceSize: const Size(800, 400),
      );
      await tester.pumpAndSettle();

      final stepper = tester.widget<OiStepper>(find.byType(OiStepper));
      // processing is index 2 (pending=0, confirmed=1, processing=2)
      expect(stepper.currentStep, 2);
    });

    testWidgets('completed steps before current are marked', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiOrderTracker(
            currentStatus: OiOrderStatus.shipped,
            label: 'Order tracker',
          ),
        ),
        surfaceSize: const Size(800, 400),
      );
      await tester.pumpAndSettle();

      final stepper = tester.widget<OiStepper>(find.byType(OiStepper));
      // shipped is index 3 → steps 0, 1, 2 should be completed
      expect(stepper.completedSteps, containsAll([0, 1, 2]));
      expect(stepper.currentStep, 3);
    });

    testWidgets('custom status labels are displayed', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiOrderTracker(
            currentStatus: OiOrderStatus.pending,
            label: 'Order tracker',
            statusLabels: {
              OiOrderStatus.pending: 'Awaiting',
              OiOrderStatus.confirmed: 'Accepted',
            },
          ),
        ),
        surfaceSize: const Size(800, 400),
      );
      await tester.pumpAndSettle();

      // Custom labels should appear in the stepper.
      expect(find.text('Awaiting'), findsOneWidget);
      expect(find.text('Accepted'), findsOneWidget);
      // Default labels for unoverridden statuses.
      expect(find.text('Processing'), findsOneWidget);
    });

    testWidgets('timeline is hidden by default', (tester) async {
      await tester.pumpObers(
        SingleChildScrollView(
          child: OiOrderTracker(
            currentStatus: OiOrderStatus.processing,
            label: 'Order tracker',
            timeline: _sampleTimeline(),
          ),
        ),
        surfaceSize: const Size(800, 600),
      );
      await tester.pumpAndSettle();

      // showTimeline defaults to false, so OiTimeline should not be present.
      expect(find.byType(OiTimeline), findsNothing);
    });

    testWidgets('timeline shows when showTimeline is true with events', (
      tester,
    ) async {
      await tester.pumpObers(
        SingleChildScrollView(
          child: OiOrderTracker(
            currentStatus: OiOrderStatus.processing,
            label: 'Order tracker',
            timeline: _sampleTimeline(),
            showTimeline: true,
          ),
        ),
        surfaceSize: const Size(800, 800),
      );
      await tester.pumpAndSettle();

      expect(find.text('Order Timeline'), findsOneWidget);
      expect(find.byType(OiTimeline), findsOneWidget);
    });

    testWidgets('cancelled status renders OiOrderStatusBadge', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiOrderTracker(
            currentStatus: OiOrderStatus.cancelled,
            label: 'Order tracker',
          ),
        ),
        surfaceSize: const Size(800, 400),
      );
      await tester.pumpAndSettle();

      // Should render an OiOrderStatusBadge for cancelled terminal state.
      expect(find.byType(OiOrderStatusBadge), findsOneWidget);
      final badge = tester.widget<OiOrderStatusBadge>(
        find.byType(OiOrderStatusBadge),
      );
      expect(badge.status, OiOrderStatus.cancelled);
      // Should show the "Cancelled" text via the badge.
      expect(find.text('Cancelled'), findsOneWidget);
      // Stepper should still be rendered.
      expect(find.byType(OiStepper), findsOneWidget);
    });

    testWidgets('refunded status renders OiOrderStatusBadge', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiOrderTracker(
            currentStatus: OiOrderStatus.refunded,
            label: 'Order tracker',
          ),
        ),
        surfaceSize: const Size(800, 400),
      );
      await tester.pumpAndSettle();

      // Should render an OiOrderStatusBadge for refunded terminal state.
      expect(find.byType(OiOrderStatusBadge), findsOneWidget);
      final badge = tester.widget<OiOrderStatusBadge>(
        find.byType(OiOrderStatusBadge),
      );
      expect(badge.status, OiOrderStatus.refunded);
      // Should show the "Refunded" text via the badge.
      expect(find.text('Refunded'), findsOneWidget);
      expect(find.byType(OiStepper), findsOneWidget);
    });

    testWidgets('non-terminal status does NOT render OiOrderStatusBadge', (
      tester,
    ) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiOrderTracker(
            currentStatus: OiOrderStatus.shipped,
            label: 'Order tracker',
          ),
        ),
        surfaceSize: const Size(800, 400),
      );
      await tester.pumpAndSettle();

      // OiOrderStatusBadge should only appear for terminal states.
      expect(find.byType(OiOrderStatusBadge), findsNothing);
    });

    testWidgets('accessibility: semantics label present', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiOrderTracker(
            currentStatus: OiOrderStatus.pending,
            label: 'Order tracker',
          ),
        ),
        surfaceSize: const Size(800, 400),
      );
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Order tracker',
        ),
        findsOneWidget,
      );
    });

    testWidgets('compact constructor extracts status from order', (
      tester,
    ) async {
      final order = OiOrderData(
        key: 'ord-1',
        orderNumber: 'ORD-001',
        createdAt: DateTime(2024),
        status: OiOrderStatus.shipped,
        items: const [
          OiCartItem(productKey: 'p1', name: 'Item', unitPrice: 10.0),
        ],
        summary: const OiCartSummary(subtotal: 10.0, total: 10.0),
        shippingAddress: const OiAddressData(firstName: 'Jane'),
        paymentMethod: const OiPaymentMethod(key: 'visa', label: 'Visa'),
        shippingMethod: const OiShippingMethod(
          key: 'std',
          label: 'Standard',
          price: 5.0,
        ),
      );

      await tester.pumpObers(
        SingleChildScrollView(child: OiOrderTracker.compact(order: order)),
        surfaceSize: const Size(800, 400),
      );
      await tester.pumpAndSettle();

      final stepper = tester.widget<OiStepper>(find.byType(OiStepper));
      // shipped is index 3
      expect(stepper.currentStep, 3);
      expect(stepper.completedSteps, containsAll([0, 1, 2]));
    });

    testWidgets('compact constructor does not show timeline', (tester) async {
      final order = OiOrderData(
        key: 'ord-1',
        orderNumber: 'ORD-001',
        createdAt: DateTime(2024),
        status: OiOrderStatus.processing,
        items: const [
          OiCartItem(productKey: 'p1', name: 'Item', unitPrice: 10.0),
        ],
        summary: const OiCartSummary(subtotal: 10.0, total: 10.0),
        shippingAddress: const OiAddressData(firstName: 'Jane'),
        paymentMethod: const OiPaymentMethod(key: 'visa', label: 'Visa'),
        shippingMethod: const OiShippingMethod(
          key: 'std',
          label: 'Standard',
          price: 5.0,
        ),
        timeline: _sampleTimeline(),
      );

      await tester.pumpObers(
        SingleChildScrollView(child: OiOrderTracker.compact(order: order)),
        surfaceSize: const Size(800, 400),
      );
      await tester.pumpAndSettle();

      // compact hides timeline even if events are present
      expect(find.byType(OiTimeline), findsNothing);
    });
  });
}
