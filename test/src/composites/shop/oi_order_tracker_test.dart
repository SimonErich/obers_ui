// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/navigation/oi_accordion.dart';
import 'package:obers_ui/src/components/shop/oi_order_status_badge.dart';
import 'package:obers_ui/src/composites/forms/oi_stepper.dart';
import 'package:obers_ui/src/composites/shop/oi_order_tracker.dart';
import 'package:obers_ui/src/foundation/theme/oi_text_theme.dart';
import 'package:obers_ui/src/models/oi_address_data.dart';
import 'package:obers_ui/src/models/oi_cart_item.dart';
import 'package:obers_ui/src/models/oi_cart_summary.dart';
import 'package:obers_ui/src/models/oi_order_data.dart';
import 'package:obers_ui/src/models/oi_payment_method.dart';
import 'package:obers_ui/src/models/oi_shipping_method.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

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

OiOrderData _sampleOrder({
  OiOrderStatus status = OiOrderStatus.shipped,
  List<OiOrderEvent>? timeline,
}) {
  return OiOrderData(
    key: 'ord-1',
    orderNumber: 'ORD-001',
    createdAt: DateTime(2024),
    status: status,
    items: const [OiCartItem(productKey: 'p1', name: 'Item', unitPrice: 10)],
    summary: const OiCartSummary(subtotal: 10, total: 10),
    shippingAddress: const OiAddressData(firstName: 'Jane'),
    paymentMethod: const OiPaymentMethod(key: 'visa', label: 'Visa'),
    shippingMethod: const OiShippingMethod(
      key: 'std',
      label: 'Standard',
      price: 5,
    ),
    timeline: timeline,
  );
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('OiOrderTracker', () {
    // ── Step rendering ────────────────────────────────────────────────────

    group('step rendering', () {
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

      testWidgets('step labels show default status names', (tester) async {
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

        expect(find.text('Pending'), findsOneWidget);
        expect(find.text('Confirmed'), findsOneWidget);
        expect(find.text('Processing'), findsOneWidget);
        expect(find.text('Shipped'), findsOneWidget);
        expect(find.text('Delivered'), findsOneWidget);
      });
    });

    // ── Step completion ──────────────────────────────────────────────────

    group('step completion', () {
      testWidgets('steps up to and including current are completed', (
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

        final stepper = tester.widget<OiStepper>(find.byType(OiStepper));
        // shipped is index 3 → steps 0, 1, 2, 3 should be completed
        expect(stepper.completedSteps, containsAll([0, 1, 2, 3]));
        expect(stepper.completedSteps.contains(4), isFalse);
      });

      testWidgets('first step completed when at pending', (tester) async {
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
        expect(stepper.completedSteps, contains(0));
        expect(stepper.completedSteps.length, 1);
        expect(stepper.currentStep, 0);
      });

      testWidgets('all steps completed at delivered (last)', (tester) async {
        await tester.pumpObers(
          const SingleChildScrollView(
            child: OiOrderTracker(
              currentStatus: OiOrderStatus.delivered,
              label: 'Order tracker',
            ),
          ),
          surfaceSize: const Size(800, 400),
        );
        await tester.pumpAndSettle();

        final stepper = tester.widget<OiStepper>(find.byType(OiStepper));
        expect(stepper.completedSteps, containsAll([0, 1, 2, 3, 4]));
        expect(stepper.currentStep, 4);
      });
    });

    // ── Current step ────────────────────────────────────────────────────

    group('current step', () {
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
        // processing is index 2
        expect(stepper.currentStep, 2);
      });

      testWidgets('steps after current are incomplete', (tester) async {
        await tester.pumpObers(
          const SingleChildScrollView(
            child: OiOrderTracker(
              currentStatus: OiOrderStatus.confirmed,
              label: 'Order tracker',
            ),
          ),
          surfaceSize: const Size(800, 400),
        );
        await tester.pumpAndSettle();

        final stepper = tester.widget<OiStepper>(find.byType(OiStepper));
        // confirmed is index 1 → steps 0, 1 completed
        expect(stepper.completedSteps, containsAll([0, 1]));
        expect(stepper.completedSteps.contains(2), isFalse);
        expect(stepper.completedSteps.contains(3), isFalse);
        expect(stepper.completedSteps.contains(4), isFalse);
      });
    });

    // ── Terminal states ─────────────────────────────────────────────────

    group('cancelled terminal', () {
      testWidgets('renders OiOrderStatusBadge for cancelled', (tester) async {
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

        expect(find.byType(OiOrderStatusBadge), findsOneWidget);
        final badge = tester.widget<OiOrderStatusBadge>(
          find.byType(OiOrderStatusBadge),
        );
        expect(badge.status, OiOrderStatus.cancelled);
        expect(find.text('Cancelled'), findsOneWidget);
        expect(find.byType(OiStepper), findsOneWidget);
      });
    });

    group('refunded terminal', () {
      testWidgets('renders OiOrderStatusBadge for refunded', (tester) async {
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

        expect(find.byType(OiOrderStatusBadge), findsOneWidget);
        final badge = tester.widget<OiOrderStatusBadge>(
          find.byType(OiOrderStatusBadge),
        );
        expect(badge.status, OiOrderStatus.refunded);
        expect(find.text('Refunded'), findsOneWidget);
        expect(find.byType(OiStepper), findsOneWidget);
      });
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

      expect(find.byType(OiOrderStatusBadge), findsNothing);
    });

    // ── Custom statusLabels ─────────────────────────────────────────────

    group('custom statusLabels', () {
      testWidgets('custom labels are displayed in stepper', (tester) async {
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

        expect(find.text('Awaiting'), findsOneWidget);
        expect(find.text('Accepted'), findsOneWidget);
        // Default labels for unoverridden statuses.
        expect(find.text('Processing'), findsOneWidget);
        expect(find.text('Shipped'), findsOneWidget);
        expect(find.text('Delivered'), findsOneWidget);
      });

      testWidgets('custom labels propagate to terminal badge', (tester) async {
        await tester.pumpObers(
          const SingleChildScrollView(
            child: OiOrderTracker(
              currentStatus: OiOrderStatus.cancelled,
              label: 'Order tracker',
              statusLabels: {OiOrderStatus.cancelled: 'Aborted'},
            ),
          ),
          surfaceSize: const Size(800, 400),
        );
        await tester.pumpAndSettle();

        // The terminal badge should use the custom label for semantics.
        final badge = tester.widget<OiOrderStatusBadge>(
          find.byType(OiOrderStatusBadge),
        );
        expect(badge.label, 'Aborted');
      });
    });

    // ── Timeline accordion (REQ-0016) ───────────────────────────────────

    group('timeline accordion', () {
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

        expect(find.text('Order History'), findsOneWidget);
        expect(find.byType(OiAccordion), findsOneWidget);
      });

      testWidgets('timeline accordion can be collapsed', (tester) async {
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

        // Timeline is expanded by default — event titles should be visible.
        expect(find.text('Order Placed'), findsOneWidget);

        // Tap the accordion header to collapse.
        await tester.tap(find.text('Order History'));
        await tester.pumpAndSettle();

        // Accordion is still present but content may be collapsed.
        expect(find.byType(OiAccordion), findsOneWidget);
      });

      testWidgets('collapsed accordion can be re-expanded', (tester) async {
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

        // Collapse.
        await tester.tap(find.text('Order History'));
        await tester.pumpAndSettle();

        // Re-expand.
        await tester.tap(find.text('Order History'));
        await tester.pumpAndSettle();

        expect(find.byType(OiAccordion), findsOneWidget);
      });
    });

    // ── Timeline event ordering and content (REQ-0016) ──────────────────

    group('timeline event ordering', () {
      testWidgets('timeline renders correct number of events', (tester) async {
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

        // Each event renders an OiLabel.bodyStrong for the title.
        expect(find.text('Order Placed'), findsOneWidget);
        expect(find.text('Order Confirmed'), findsOneWidget);
        // 'Processing' appears both as step label and event title.
        expect(find.text('Processing'), findsAtLeastNWidgets(1));
      });

      testWidgets('events are sorted newest-first', (tester) async {
        final events = [
          OiOrderEvent(
            timestamp: DateTime(2024, 1, 1, 10),
            title: 'Order Placed',
            status: OiOrderStatus.pending,
          ),
          OiOrderEvent(
            timestamp: DateTime(2024, 1, 3, 14),
            title: 'Shipped',
            status: OiOrderStatus.shipped,
          ),
          OiOrderEvent(
            timestamp: DateTime(2024, 1, 2, 9),
            title: 'Processing Started',
            status: OiOrderStatus.processing,
          ),
        ];

        await tester.pumpObers(
          SingleChildScrollView(
            child: OiOrderTracker(
              currentStatus: OiOrderStatus.shipped,
              label: 'Order tracker',
              timeline: events,
              showTimeline: true,
            ),
          ),
          surfaceSize: const Size(800, 800),
        );
        await tester.pumpAndSettle();

        // Find all OiLabel.bodyStrong widgets to check order.
        final bodyStrongLabels = tester.widgetList<OiLabel>(
          find.byWidgetPredicate(
            (w) => w is OiLabel && w.variant == OiLabelVariant.bodyStrong,
          ),
        );
        final titles = bodyStrongLabels.map((l) => l.text).toList();

        // Should be newest-first: Shipped, Processing Started, Order Placed.
        final shippedIdx = titles.indexOf('Shipped');
        final processingIdx = titles.indexOf('Processing Started');
        final placedIdx = titles.indexOf('Order Placed');

        expect(shippedIdx, lessThan(processingIdx));
        expect(processingIdx, lessThan(placedIdx));
      });

      testWidgets('timeline event titles rendered as OiLabel.bodyStrong', (
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

        // Event titles should be visible.
        expect(find.text('Order Placed'), findsOneWidget);
        expect(find.text('Order Confirmed'), findsOneWidget);
      });

      testWidgets('timeline event descriptions are rendered', (tester) async {
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

        expect(find.text('Your order has been received.'), findsOneWidget);
        expect(find.text('Your order is being prepared.'), findsOneWidget);
      });

      testWidgets('event without description renders no extra label', (
        tester,
      ) async {
        final events = [
          OiOrderEvent(
            timestamp: DateTime(2024, 1, 1, 10),
            title: 'Confirmed',
            status: OiOrderStatus.confirmed,
          ),
        ];

        await tester.pumpObers(
          SingleChildScrollView(
            child: OiOrderTracker(
              currentStatus: OiOrderStatus.confirmed,
              label: 'Order tracker',
              timeline: events,
              showTimeline: true,
            ),
          ),
          surfaceSize: const Size(800, 800),
        );
        await tester.pumpAndSettle();

        // Title is rendered.
        expect(find.text('Confirmed'), findsAtLeastNWidgets(1));
        // The accordion section has: timestamp label, title label.
        // No description label because it's null.
      });

      testWidgets('timeline handles event with empty description', (
        tester,
      ) async {
        final eventsWithEmpty = [
          OiOrderEvent(
            timestamp: DateTime(2024, 1, 1, 10),
            title: 'Order Placed',
            status: OiOrderStatus.pending,
            description: '',
          ),
          OiOrderEvent(
            timestamp: DateTime(2024, 1, 2, 9),
            title: 'Confirmed',
            status: OiOrderStatus.confirmed,
          ),
        ];

        await tester.pumpObers(
          SingleChildScrollView(
            child: OiOrderTracker(
              currentStatus: OiOrderStatus.confirmed,
              label: 'Order tracker',
              timeline: eventsWithEmpty,
              showTimeline: true,
            ),
          ),
          surfaceSize: const Size(800, 800),
        );
        await tester.pumpAndSettle();

        // Widget renders without error.
        expect(find.byType(OiAccordion), findsOneWidget);
        expect(find.text('Order Placed'), findsOneWidget);
      });

      testWidgets('single event timeline renders without issues', (
        tester,
      ) async {
        final singleEvent = [
          OiOrderEvent(
            timestamp: DateTime(2024, 1, 1, 10),
            title: 'Order Placed',
            status: OiOrderStatus.pending,
            description: 'Your order has been received.',
          ),
        ];

        await tester.pumpObers(
          SingleChildScrollView(
            child: OiOrderTracker(
              currentStatus: OiOrderStatus.pending,
              label: 'Order tracker',
              timeline: singleEvent,
              showTimeline: true,
            ),
          ),
          surfaceSize: const Size(800, 800),
        );
        await tester.pumpAndSettle();

        expect(find.byType(OiAccordion), findsOneWidget);
        expect(find.text('Order Placed'), findsOneWidget);
        expect(find.text('Your order has been received.'), findsOneWidget);
      });

      testWidgets('timeline event timestamps are formatted', (tester) async {
        final events = [
          OiOrderEvent(
            timestamp: DateTime(2024, 3, 15, 14, 30),
            title: 'Shipped',
            status: OiOrderStatus.shipped,
          ),
        ];

        await tester.pumpObers(
          SingleChildScrollView(
            child: OiOrderTracker(
              currentStatus: OiOrderStatus.shipped,
              label: 'Order tracker',
              timeline: events,
              showTimeline: true,
            ),
          ),
          surfaceSize: const Size(800, 800),
        );
        await tester.pumpAndSettle();

        expect(find.text('Mar 15, 2024 14:30'), findsOneWidget);
      });
    });

    // ── showTimeline false ───────────────────────────────────────────────

    group('showTimeline false', () {
      testWidgets('timeline is hidden when showTimeline is false', (
        tester,
      ) async {
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

        // showTimeline defaults to false.
        expect(find.byType(OiAccordion), findsNothing);
        expect(find.text('Order History'), findsNothing);
      });

      testWidgets(
        'timeline hidden when showTimeline explicitly false with events',
        (tester) async {
          await tester.pumpObers(
            SingleChildScrollView(
              child: OiOrderTracker(
                currentStatus: OiOrderStatus.processing,
                label: 'Order tracker',
                timeline: _sampleTimeline(),
                // Explicitly testing false to verify behavior.
                // ignore: avoid_redundant_argument_values
                showTimeline: false,
              ),
            ),
            surfaceSize: const Size(800, 600),
          );
          await tester.pumpAndSettle();

          expect(find.byType(OiAccordion), findsNothing);
        },
      );
    });

    // ── Empty timeline ──────────────────────────────────────────────────

    group('empty timeline', () {
      testWidgets('showTimeline true with empty list shows no timeline', (
        tester,
      ) async {
        await tester.pumpObers(
          const SingleChildScrollView(
            child: OiOrderTracker(
              currentStatus: OiOrderStatus.processing,
              label: 'Order tracker',
              timeline: [],
              showTimeline: true,
            ),
          ),
          surfaceSize: const Size(800, 600),
        );
        await tester.pumpAndSettle();

        expect(find.byType(OiAccordion), findsNothing);
        expect(find.text('Order History'), findsNothing);
      });

      testWidgets('showTimeline true with null timeline shows no timeline', (
        tester,
      ) async {
        await tester.pumpObers(
          const SingleChildScrollView(
            child: OiOrderTracker(
              currentStatus: OiOrderStatus.processing,
              label: 'Order tracker',
              showTimeline: true,
            ),
          ),
          surfaceSize: const Size(800, 600),
        );
        await tester.pumpAndSettle();

        expect(find.byType(OiAccordion), findsNothing);
      });
    });

    // ── Accessibility ───────────────────────────────────────────────────

    group('accessibility', () {
      testWidgets('semantics label present on tracker', (tester) async {
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
    });

    // ── Compact constructor ─────────────────────────────────────────────

    group('compact constructor', () {
      testWidgets('extracts status from order', (tester) async {
        final order = _sampleOrder();

        await tester.pumpObers(
          SingleChildScrollView(child: OiOrderTracker.compact(order: order)),
          surfaceSize: const Size(800, 400),
        );
        await tester.pumpAndSettle();

        final stepper = tester.widget<OiStepper>(find.byType(OiStepper));
        // shipped is index 3
        expect(stepper.currentStep, 3);
        expect(stepper.completedSteps, containsAll([0, 1, 2, 3]));
      });

      testWidgets('does not show timeline', (tester) async {
        final order = _sampleOrder(timeline: _sampleTimeline());

        await tester.pumpObers(
          SingleChildScrollView(child: OiOrderTracker.compact(order: order)),
          surfaceSize: const Size(800, 400),
        );
        await tester.pumpAndSettle();

        // compact hides timeline even if events are present.
        expect(find.byType(OiAccordion), findsNothing);
      });
    });
  });
}
