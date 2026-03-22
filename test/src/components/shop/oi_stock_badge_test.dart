// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/shop/oi_stock_badge.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiStockBadge', () {
    testWidgets('inStock shows "In Stock" text', (tester) async {
      await tester.pumpObers(
        const OiStockBadge(
          status: OiStockStatus.inStock,
          label: 'Stock status',
        ),
      );

      expect(find.text('In Stock'), findsOneWidget);
    });

    testWidgets('lowStock shows "Low Stock" text', (tester) async {
      await tester.pumpObers(
        const OiStockBadge(
          status: OiStockStatus.lowStock,
          label: 'Stock status',
        ),
      );

      expect(find.text('Low Stock'), findsOneWidget);
    });

    testWidgets('outOfStock shows "Out of Stock" text', (tester) async {
      await tester.pumpObers(
        const OiStockBadge(
          status: OiStockStatus.outOfStock,
          label: 'Stock status',
        ),
      );

      expect(find.text('Out of Stock'), findsOneWidget);
    });

    testWidgets('inStock with count shows count in parentheses', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiStockBadge(
          status: OiStockStatus.inStock,
          label: 'Stock status',
          count: 42,
        ),
      );

      expect(find.text('In Stock (42)'), findsOneWidget);
    });

    testWidgets('lowStock with count shows "N left"', (tester) async {
      await tester.pumpObers(
        const OiStockBadge(
          status: OiStockStatus.lowStock,
          label: 'Stock status',
          count: 3,
        ),
      );

      expect(find.text('Low Stock (3 left)'), findsOneWidget);
    });

    testWidgets('fromCount: null stockCount defaults to inStock', (
      tester,
    ) async {
      await tester.pumpObers(
        OiStockBadge.fromCount(stockCount: null, label: 'Stock status'),
      );

      expect(find.text('In Stock'), findsOneWidget);
    });

    testWidgets('fromCount: 0 produces outOfStock', (tester) async {
      await tester.pumpObers(
        OiStockBadge.fromCount(stockCount: 0, label: 'Stock status'),
      );

      expect(find.text('Out of Stock'), findsOneWidget);
    });

    testWidgets('fromCount: low count produces lowStock', (tester) async {
      await tester.pumpObers(
        OiStockBadge.fromCount(stockCount: 3, label: 'Stock status'),
      );

      expect(find.text('Low Stock (3 left)'), findsOneWidget);
    });

    testWidgets('fromCount: high count produces inStock', (tester) async {
      await tester.pumpObers(
        OiStockBadge.fromCount(stockCount: 50, label: 'Stock status'),
      );

      expect(find.text('In Stock (50)'), findsOneWidget);
    });

    testWidgets('fromCount: custom threshold', (tester) async {
      await tester.pumpObers(
        OiStockBadge.fromCount(
          stockCount: 8,
          label: 'Stock status',
          lowStockThreshold: 10,
        ),
      );

      expect(find.text('Low Stock (8 left)'), findsOneWidget);
    });

    testWidgets('semantic label is set', (tester) async {
      await tester.pumpObers(
        const OiStockBadge(
          status: OiStockStatus.inStock,
          label: 'Availability',
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Availability',
        ),
        findsOneWidget,
      );
    });
  });
}
