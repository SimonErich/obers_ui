// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/shop/oi_order_status_badge.dart';
import 'package:obers_ui/src/composites/forms/oi_stepper.dart';
import 'package:obers_ui/src/composites/scheduling/oi_timeline.dart';
import 'package:obers_ui/src/composites/shop/oi_order_tracker.dart';
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
      testWidgets('steps before current are completed', (tester) async {
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
        expect(stepper.completedSteps.contains(3), isFalse);
      });

      testWidgets('no steps completed when at pending (first)', (tester) async {
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
        expect(stepper.completedSteps, isEmpty);
        expect(stepper.currentStep, 0);
      });

      testWidgets('all prior steps completed at delivered (last)', (
        tester,
      ) async {
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
        expect(stepper.completedSteps, containsAll([0, 1, 2, 3]));
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
        // confirmed is index 1 → only step 0 completed
        expect(stepper.completedSteps, contains(0));
        expect(stepper.completedSteps.contains(1), isFalse);
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

    // ── Timeline accordion ──────────────────────────────────────────────

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

        expect(find.text('Order Timeline'), findsOneWidget);
        expect(find.byType(OiTimeline), findsOneWidget);
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

        // Timeline is expanded by default.
        expect(find.byType(OiTimeline), findsOneWidget);

        // Tap the accordion header to collapse.
        await tester.tap(find.text('Order Timeline'));
        await tester.pumpAndSettle();

        // Timeline should now be hidden.
        expect(find.byType(OiTimeline), findsNothing);
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
        await tester.tap(find.text('Order Timeline'));
        await tester.pumpAndSettle();
        expect(find.byType(OiTimeline), findsNothing);

        // Re-expand.
        await tester.tap(find.text('Order Timeline'));
        await tester.pumpAndSettle();
        expect(find.byType(OiTimeline), findsOneWidget);
      });
    });

    // ── Timeline event ordering and content ─────────────────────────────
    //
    // Note: OiOrderTracker composes OiTimeline (not OiAccordion) for the
    // event list. OiTimeline renders events in the order they are passed —
    // it does not sort internally. The caller is responsible for providing
    // events in the desired display order.

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

        final timeline = tester.widget<OiTimeline>(find.byType(OiTimeline));
        expect(timeline.events.length, 3);
      });

      testWidgets('timeline events preserve original order', (tester) async {
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

        final timeline = tester.widget<OiTimeline>(find.byType(OiTimeline));
        expect(timeline.events[0].title, 'Order Placed');
        expect(timeline.events[1].title, 'Order Confirmed');
        expect(timeline.events[2].title, 'Processing');
      });

      testWidgets('timeline events sorted newest-first render correctly', (
        tester,
      ) async {
        // When caller passes events in newest-first (descending) order,
        // OiTimeline renders them in that same order. Sorting is the
        // caller's responsibility — OiOrderTracker passes events through
        // to OiTimeline without re-ordering.
        final newestFirstEvents = [
          OiOrderEvent(
            timestamp: DateTime(2024, 1, 3, 14),
            title: 'Shipped',
            status: OiOrderStatus.shipped,
            description: 'Package left the warehouse.',
          ),
          OiOrderEvent(
            timestamp: DateTime(2024, 1, 2, 9),
            title: 'Processing',
            status: OiOrderStatus.processing,
          ),
          OiOrderEvent(
            timestamp: DateTime(2024, 1, 1, 10),
            title: 'Order Placed',
            status: OiOrderStatus.pending,
          ),
        ];

        await tester.pumpObers(
          SingleChildScrollView(
            child: OiOrderTracker(
              currentStatus: OiOrderStatus.shipped,
              label: 'Order tracker',
              timeline: newestFirstEvents,
              showTimeline: true,
            ),
          ),
          surfaceSize: const Size(800, 800),
        );
        await tester.pumpAndSettle();

        final timeline = tester.widget<OiTimeline>(find.byType(OiTimeline));
        // Verify newest-first ordering is preserved in the OiTimeline widget.
        expect(timeline.events[0].title, 'Shipped');
        expect(timeline.events[1].title, 'Processing');
        expect(timeline.events[2].title, 'Order Placed');

        // Verify all titles are rendered in the widget tree.
        final titleWidgets = tester.widgetList<Text>(find.text('Shipped'));
        expect(titleWidgets, isNotEmpty);
        expect(find.text('Processing'), findsAtLeastNWidgets(1));
        expect(find.text('Order Placed'), findsOneWidget);
      });

      testWidgets('timeline event titles are rendered', (tester) async {
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
        expect(find.text('Processing'), findsAtLeastNWidgets(1));
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

        // Descriptions from _sampleTimeline() that are non-null should be
        // rendered as Text widgets within OiTimeline entries.
        expect(find.text('Your order has been received.'), findsOneWidget);
        expect(find.text('Your order is being prepared.'), findsOneWidget);

        // The second event has no description — verify it does not
        // produce a spurious text widget.
        expect(find.textContaining('Order Confirmed'), findsOneWidget);
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
        expect(find.byType(OiTimeline), findsOneWidget);
        expect(find.text('Order Placed'), findsOneWidget);
        expect(find.text('Confirmed'), findsAtLeastNWidgets(1));
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

        final timeline = tester.widget<OiTimeline>(find.byType(OiTimeline));
        expect(timeline.events.length, 1);
        expect(find.text('Order Placed'), findsOneWidget);
        expect(find.text('Your order has been received.'), findsOneWidget);
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
        expect(find.byType(OiTimeline), findsNothing);
        expect(find.text('Order Timeline'), findsNothing);
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

          expect(find.byType(OiTimeline), findsNothing);
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

        expect(find.byType(OiTimeline), findsNothing);
        expect(find.text('Order Timeline'), findsNothing);
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

        expect(find.byType(OiTimeline), findsNothing);
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

      testWidgets('timeline section has accessibility label', (tester) async {
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

        // OiTimeline has its own label.
        final timeline = tester.widget<OiTimeline>(find.byType(OiTimeline));
        expect(timeline.label, 'Order timeline');
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
        expect(stepper.completedSteps, containsAll([0, 1, 2]));
      });

      testWidgets('does not show timeline', (tester) async {
        final order = _sampleOrder(timeline: _sampleTimeline());

        await tester.pumpObers(
          SingleChildScrollView(child: OiOrderTracker.compact(order: order)),
          surfaceSize: const Size(800, 400),
        );
        await tester.pumpAndSettle();

        // compact hides timeline even if events are present.
        expect(find.byType(OiTimeline), findsNothing);
      });
    });
  });
}
