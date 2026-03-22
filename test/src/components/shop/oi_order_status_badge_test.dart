// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/shop/oi_order_status_badge.dart';
import 'package:obers_ui/src/models/oi_address_data.dart';
import 'package:obers_ui/src/models/oi_cart_item.dart';
import 'package:obers_ui/src/models/oi_cart_summary.dart';
import 'package:obers_ui/src/models/oi_order_data.dart';
import 'package:obers_ui/src/models/oi_payment_method.dart';
import 'package:obers_ui/src/models/oi_shipping_method.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiOrderStatusBadge', () {
    // ── Default labels ──────────────────────────────────────────────────────

    group('default labels', () {
      testWidgets('pending renders "Pending"', (tester) async {
        await tester.pumpObers(
          const OiOrderStatusBadge(
            status: OiOrderStatus.pending,
            label: 'Order status',
          ),
        );
        expect(find.text('Pending'), findsOneWidget);
      });

      testWidgets('confirmed renders "Confirmed"', (tester) async {
        await tester.pumpObers(
          const OiOrderStatusBadge(
            status: OiOrderStatus.confirmed,
            label: 'Order status',
          ),
        );
        expect(find.text('Confirmed'), findsOneWidget);
      });

      testWidgets('processing renders "Processing"', (tester) async {
        await tester.pumpObers(
          const OiOrderStatusBadge(
            status: OiOrderStatus.processing,
            label: 'Order status',
          ),
        );
        expect(find.text('Processing'), findsOneWidget);
      });

      testWidgets('shipped renders "Shipped"', (tester) async {
        await tester.pumpObers(
          const OiOrderStatusBadge(
            status: OiOrderStatus.shipped,
            label: 'Order status',
          ),
        );
        expect(find.text('Shipped'), findsOneWidget);
      });

      testWidgets('delivered renders "Delivered"', (tester) async {
        await tester.pumpObers(
          const OiOrderStatusBadge(
            status: OiOrderStatus.delivered,
            label: 'Order status',
          ),
        );
        expect(find.text('Delivered'), findsOneWidget);
      });

      testWidgets('cancelled renders "Cancelled"', (tester) async {
        await tester.pumpObers(
          const OiOrderStatusBadge(
            status: OiOrderStatus.cancelled,
            label: 'Order status',
          ),
        );
        expect(find.text('Cancelled'), findsOneWidget);
      });

      testWidgets('refunded renders "Refunded"', (tester) async {
        await tester.pumpObers(
          const OiOrderStatusBadge(
            status: OiOrderStatus.refunded,
            label: 'Order status',
          ),
        );
        expect(find.text('Refunded'), findsOneWidget);
      });
    });

    // ── Default colors ──────────────────────────────────────────────────────

    group('default colors', () {
      testWidgets('pending uses warning color', (tester) async {
        await tester.pumpObers(
          const OiOrderStatusBadge(
            status: OiOrderStatus.pending,
            label: 'Order status',
          ),
        );
        final badge = tester.widget<OiBadge>(find.byType(OiBadge));
        expect(badge.color, OiBadgeColor.warning);
      });

      testWidgets('confirmed uses info color', (tester) async {
        await tester.pumpObers(
          const OiOrderStatusBadge(
            status: OiOrderStatus.confirmed,
            label: 'Order status',
          ),
        );
        final badge = tester.widget<OiBadge>(find.byType(OiBadge));
        expect(badge.color, OiBadgeColor.info);
      });

      testWidgets('processing uses info color', (tester) async {
        await tester.pumpObers(
          const OiOrderStatusBadge(
            status: OiOrderStatus.processing,
            label: 'Order status',
          ),
        );
        final badge = tester.widget<OiBadge>(find.byType(OiBadge));
        expect(badge.color, OiBadgeColor.info);
      });

      testWidgets('shipped uses primary color', (tester) async {
        await tester.pumpObers(
          const OiOrderStatusBadge(
            status: OiOrderStatus.shipped,
            label: 'Order status',
          ),
        );
        final badge = tester.widget<OiBadge>(find.byType(OiBadge));
        expect(badge.color, OiBadgeColor.primary);
      });

      testWidgets('delivered uses success color', (tester) async {
        await tester.pumpObers(
          const OiOrderStatusBadge(
            status: OiOrderStatus.delivered,
            label: 'Order status',
          ),
        );
        final badge = tester.widget<OiBadge>(find.byType(OiBadge));
        expect(badge.color, OiBadgeColor.success);
      });

      testWidgets('cancelled uses error color', (tester) async {
        await tester.pumpObers(
          const OiOrderStatusBadge(
            status: OiOrderStatus.cancelled,
            label: 'Order status',
          ),
        );
        final badge = tester.widget<OiBadge>(find.byType(OiBadge));
        expect(badge.color, OiBadgeColor.error);
      });

      testWidgets('refunded uses neutral color', (tester) async {
        await tester.pumpObers(
          const OiOrderStatusBadge(
            status: OiOrderStatus.refunded,
            label: 'Order status',
          ),
        );
        final badge = tester.widget<OiBadge>(find.byType(OiBadge));
        expect(badge.color, OiBadgeColor.neutral);
      });
    });

    // ── Custom statusColors ────────────────────────────────────────────────

    group('custom statusColors', () {
      testWidgets('statusColors overrides default badge color', (tester) async {
        await tester.pumpObers(
          const OiOrderStatusBadge(
            status: OiOrderStatus.pending,
            label: 'Order status',
            statusColors: {OiOrderStatus.pending: OiBadgeColor.success},
          ),
        );
        final badge = tester.widget<OiBadge>(find.byType(OiBadge));
        expect(badge.color, OiBadgeColor.success);
      });

      testWidgets('unoverridden status uses default color', (tester) async {
        await tester.pumpObers(
          const OiOrderStatusBadge(
            status: OiOrderStatus.shipped,
            label: 'Order status',
            statusColors: {OiOrderStatus.pending: OiBadgeColor.success},
          ),
        );
        final badge = tester.widget<OiBadge>(find.byType(OiBadge));
        expect(badge.color, OiBadgeColor.primary);
      });

      testWidgets('all statuses can be overridden', (tester) async {
        await tester.pumpObers(
          const OiOrderStatusBadge(
            status: OiOrderStatus.delivered,
            label: 'Order status',
            statusColors: {OiOrderStatus.delivered: OiBadgeColor.warning},
          ),
        );
        final badge = tester.widget<OiBadge>(find.byType(OiBadge));
        expect(badge.color, OiBadgeColor.warning);
      });
    });

    // ── Custom statusLabels ──────────────────────────────────────────────

    group('custom statusLabels', () {
      testWidgets('statusLabels overrides default text', (tester) async {
        await tester.pumpObers(
          const OiOrderStatusBadge(
            status: OiOrderStatus.pending,
            label: 'Order status',
            statusLabels: {OiOrderStatus.pending: 'Ausstehend'},
          ),
        );
        expect(find.text('Ausstehend'), findsOneWidget);
        expect(find.text('Pending'), findsNothing);
      });

      testWidgets('unoverridden status uses default label', (tester) async {
        await tester.pumpObers(
          const OiOrderStatusBadge(
            status: OiOrderStatus.shipped,
            label: 'Order status',
            statusLabels: {OiOrderStatus.pending: 'Ausstehend'},
          ),
        );
        expect(find.text('Shipped'), findsOneWidget);
      });

      testWidgets('all statuses can be overridden', (tester) async {
        await tester.pumpObers(
          const OiOrderStatusBadge(
            status: OiOrderStatus.delivered,
            label: 'Order status',
            statusLabels: {OiOrderStatus.delivered: 'Geliefert'},
          ),
        );
        expect(find.text('Geliefert'), findsOneWidget);
        expect(find.text('Delivered'), findsNothing);
      });
    });

    // ── Constructors ────────────────────────────────────────────────────────

    group('constructors', () {
      testWidgets('soft constructor renders soft badge', (tester) async {
        await tester.pumpObers(
          const OiOrderStatusBadge.soft(
            status: OiOrderStatus.shipped,
            label: 'Order status',
          ),
        );
        final badge = tester.widget<OiBadge>(find.byType(OiBadge));
        expect(badge.style, OiBadgeStyle.soft);
        expect(find.text('Shipped'), findsOneWidget);
      });

      testWidgets('filled constructor renders filled badge', (tester) async {
        await tester.pumpObers(
          const OiOrderStatusBadge.filled(
            status: OiOrderStatus.delivered,
            label: 'Order status',
          ),
        );
        final badge = tester.widget<OiBadge>(find.byType(OiBadge));
        expect(badge.style, OiBadgeStyle.filled);
        expect(find.text('Delivered'), findsOneWidget);
      });

      testWidgets('fromOrder extracts status from order', (tester) async {
        final order = OiOrderData(
          key: 'ord-1',
          orderNumber: 'ORD-001',
          createdAt: DateTime(2024),
          status: OiOrderStatus.shipped,
          items: const [
            OiCartItem(productKey: 'p1', name: 'Item', unitPrice: 10),
          ],
          summary: const OiCartSummary(subtotal: 10, total: 10),
          shippingAddress: const OiAddressData(firstName: 'Jane'),
          paymentMethod: const OiPaymentMethod(key: 'visa', label: 'Visa'),
          shippingMethod: const OiShippingMethod(
            key: 'std',
            label: 'Standard',
            price: 5,
          ),
        );

        await tester.pumpObers(OiOrderStatusBadge.fromOrder(order: order));
        expect(find.text('Shipped'), findsOneWidget);
      });
    });

    // ── Accessibility ───────────────────────────────────────────────────────

    group('accessibility', () {
      testWidgets('semantic label is set', (tester) async {
        await tester.pumpObers(
          const OiOrderStatusBadge(
            status: OiOrderStatus.pending,
            label: 'Current order status',
          ),
        );

        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Semantics && w.properties.label == 'Current order status',
          ),
          findsOneWidget,
        );
      });

      testWidgets('inner badge text is excluded from semantics', (
        tester,
      ) async {
        await tester.pumpObers(
          const OiOrderStatusBadge(
            status: OiOrderStatus.delivered,
            label: 'Order status',
          ),
        );

        // The OiOrderStatusBadge wraps its inner badge in ExcludeSemantics.
        expect(find.byType(ExcludeSemantics), findsAtLeastNWidgets(1));
      });
    });
  });
}
