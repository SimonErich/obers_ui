// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_checkbox.dart';
import 'package:obers_ui/src/components/inputs/oi_switch.dart';
import 'package:obers_ui/src/composites/shop/oi_product_filters.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiProductFilters', () {
    testWidgets('renders price range section', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(child: OiProductFilters(label: 'Filters')),
      );

      expect(find.text('Price Range'), findsOneWidget);
    });

    testWidgets('renders rating section', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(child: OiProductFilters(label: 'Filters')),
      );

      expect(find.text('Minimum Rating'), findsOneWidget);
    });

    testWidgets('renders stock filter switch', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(child: OiProductFilters(label: 'Filters')),
      );

      expect(find.text('In Stock Only'), findsOneWidget);
      expect(find.byType(OiSwitch), findsOneWidget);
    });

    testWidgets('renders category checkboxes when categories provided', (
      tester,
    ) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiProductFilters(
            label: 'Filters',
            availableCategories: ['Shirts', 'Pants', 'Shoes'],
          ),
        ),
      );

      expect(find.text('Category'), findsOneWidget);
      expect(find.byType(OiCheckbox), findsNWidgets(3));
    });

    testWidgets('hides category section when no categories', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(child: OiProductFilters(label: 'Filters')),
      );

      expect(find.text('Category'), findsNothing);
      expect(find.byType(OiCheckbox), findsNothing);
    });

    testWidgets('toggling category fires onChanged', (tester) async {
      OiProductFilterData? received;
      await tester.pumpObers(
        SingleChildScrollView(
          child: OiProductFilters(
            label: 'Filters',
            availableCategories: const ['Shirts', 'Pants'],
            onChanged: (data) => received = data,
          ),
        ),
      );

      // Tap the first checkbox (Shirts).
      await tester.tap(find.byType(OiCheckbox).first);
      await tester.pump();

      expect(received, isNotNull);
      expect(received!.categories, contains('Shirts'));
    });

    testWidgets('toggling stock filter fires onChanged', (tester) async {
      OiProductFilterData? received;
      await tester.pumpObers(
        SingleChildScrollView(
          child: OiProductFilters(
            label: 'Filters',
            onChanged: (data) => received = data,
          ),
        ),
      );

      await tester.tap(find.byType(OiSwitch));
      await tester.pump();

      expect(received, isNotNull);
      expect(received!.inStockOnly, isTrue);
    });

    testWidgets('displays currency formatted price labels', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiProductFilters(label: 'Filters', priceRangeMax: 500),
        ),
      );

      expect(find.text('0 €'), findsOneWidget);
      expect(find.text('500 €'), findsOneWidget);
    });

    testWidgets('semantic label is set', (tester) async {
      await tester.pumpObers(
        const SingleChildScrollView(
          child: OiProductFilters(label: 'Product filters'),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Product filters',
        ),
        findsOneWidget,
      );
    });

    testWidgets('OiProductFilterData equality and copyWith', (tester) async {
      const a = OiProductFilterData(
        minPrice: 10,
        maxPrice: 100,
        categories: ['A'],
        minRating: 3,
        inStockOnly: true,
      );

      const b = OiProductFilterData(
        minPrice: 10,
        maxPrice: 100,
        categories: ['A'],
        minRating: 3,
        inStockOnly: true,
      );

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);

      final c = a.copyWith(minPrice: 20);
      expect(c.minPrice, 20);
      expect(c.maxPrice, 100);

      final d = a.copyWith(minPrice: null);
      expect(d.minPrice, isNull);
    });
  });
}
