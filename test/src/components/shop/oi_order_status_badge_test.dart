// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
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
    testWidgets('pending shows "Pending" text', (tester) async {
      await tester.pumpObers(
        const OiOrderStatusBadge(
          status: OiOrderStatus.pending,
          label: 'Order status',
        ),
      );

      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('processing shows "Processing" text', (tester) async {
      await tester.pumpObers(
        const OiOrderStatusBadge(
          status: OiOrderStatus.processing,
          label: 'Order status',
        ),
      );

      expect(find.text('Processing'), findsOneWidget);
    });

    testWidgets('shipped shows "Shipped" text', (tester) async {
      await tester.pumpObers(
        const OiOrderStatusBadge(
          status: OiOrderStatus.shipped,
          label: 'Order status',
        ),
      );

      expect(find.text('Shipped'), findsOneWidget);
    });

    testWidgets('delivered shows "Delivered" text', (tester) async {
      await tester.pumpObers(
        const OiOrderStatusBadge(
          status: OiOrderStatus.delivered,
          label: 'Order status',
        ),
      );

      expect(find.text('Delivered'), findsOneWidget);
    });

    testWidgets('cancelled shows "Cancelled" text', (tester) async {
      await tester.pumpObers(
        const OiOrderStatusBadge(
          status: OiOrderStatus.cancelled,
          label: 'Order status',
        ),
      );

      expect(find.text('Cancelled'), findsOneWidget);
    });

    testWidgets('confirmed shows "Confirmed" text', (tester) async {
      await tester.pumpObers(
        const OiOrderStatusBadge(
          status: OiOrderStatus.confirmed,
          label: 'Order status',
        ),
      );

      expect(find.text('Confirmed'), findsOneWidget);
    });

    testWidgets('refunded shows "Refunded" text', (tester) async {
      await tester.pumpObers(
        const OiOrderStatusBadge(
          status: OiOrderStatus.refunded,
          label: 'Order status',
        ),
      );

      expect(find.text('Refunded'), findsOneWidget);
    });

    testWidgets('soft constructor renders without error', (tester) async {
      await tester.pumpObers(
        const OiOrderStatusBadge.soft(
          status: OiOrderStatus.shipped,
          label: 'Order status',
        ),
      );

      expect(find.text('Shipped'), findsOneWidget);
    });

    testWidgets('filled constructor renders without error', (tester) async {
      await tester.pumpObers(
        const OiOrderStatusBadge.filled(
          status: OiOrderStatus.delivered,
          label: 'Order status',
        ),
      );

      expect(find.text('Delivered'), findsOneWidget);
    });

    testWidgets('semantic label is set', (tester) async {
      await tester.pumpObers(
        const OiOrderStatusBadge(
          status: OiOrderStatus.pending,
          label: 'Current order status',
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Current order status',
        ),
        findsOneWidget,
      );
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
}
