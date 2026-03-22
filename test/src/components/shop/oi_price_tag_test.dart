// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/shop/oi_price_tag.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiPriceTag', () {
    testWidgets('renders formatted price with correct decimal places', (
      tester,
    ) async {
      await tester.pumpObers(const OiPriceTag(price: 42.99, label: 'Price'));
      expect(find.text(r'$42.99'), findsOneWidget);
    });

    testWidgets('shows currency symbol before amount for USD', (tester) async {
      await tester.pumpObers(
        const OiPriceTag(price: 42.99, label: 'Price', currencyCode: 'USD'),
      );
      expect(find.text(r'$42.99'), findsOneWidget);
    });

    testWidgets('shows currency symbol after amount for EUR', (tester) async {
      await tester.pumpObers(
        const OiPriceTag(price: 42.99, label: 'Price', currencyCode: 'EUR'),
      );
      expect(find.text('42.99 €'), findsOneWidget);
    });

    testWidgets('shows "Free" when price is 0', (tester) async {
      await tester.pumpObers(const OiPriceTag(price: 0, label: 'Price'));
      expect(find.text('Free'), findsOneWidget);
    });

    testWidgets(
      'shows compare-at price with strikethrough when compareAtPrice > price',
      (tester) async {
        await tester.pumpObers(
          const OiPriceTag(price: 29.99, label: 'Price', compareAtPrice: 59.99),
        );
        // Both prices should be rendered.
        expect(find.text(r'$59.99'), findsOneWidget);
        expect(find.text(r'$29.99'), findsOneWidget);

        // The compare-at price should have line-through decoration.
        final compareWidget = tester.widget<Text>(find.text(r'$59.99'));
        expect(compareWidget.style?.decoration, TextDecoration.lineThrough);
      },
    );

    testWidgets('ignores compare-at when compareAtPrice <= price', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiPriceTag(price: 59.99, label: 'Price', compareAtPrice: 29.99),
      );
      // Only current price shown — compare-at ignored.
      expect(find.text(r'$59.99'), findsOneWidget);
      expect(find.text(r'$29.99'), findsNothing);
    });

    testWidgets('shows negative price in success color', (tester) async {
      await tester.pumpObers(const OiPriceTag(price: -5, label: 'Discount'));
      final context = tester.element(find.byType(OiPriceTag));
      final successColor = OiTheme.of(context).colors.success.base;
      final textWidget = tester.widget<Text>(find.text(r'-$5.00'));
      expect(textWidget.style?.color, equals(successColor));
    });

    testWidgets('current price bold when on sale', (tester) async {
      await tester.pumpObers(
        const OiPriceTag(price: 29.99, label: 'Price', compareAtPrice: 59.99),
      );
      final priceWidget = tester.widget<Text>(find.text(r'$29.99'));
      expect(priceWidget.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('respects decimalPlaces parameter', (tester) async {
      await tester.pumpObers(
        const OiPriceTag(price: 42.995, label: 'Price', decimalPlaces: 0),
      );
      expect(find.text(r'$43'), findsOneWidget);
    });

    testWidgets('renders small size with appropriate font', (tester) async {
      await tester.pumpObers(
        const OiPriceTag(price: 10, label: 'Price', size: OiPriceTagSize.small),
      );
      final textWidget = tester.widget<Text>(find.text(r'$10.00'));
      expect(textWidget.style?.fontSize, 12);
    });

    testWidgets('renders medium size with appropriate font', (tester) async {
      await tester.pumpObers(const OiPriceTag(price: 10, label: 'Price'));
      final textWidget = tester.widget<Text>(find.text(r'$10.00'));
      expect(textWidget.style?.fontSize, 14);
    });

    testWidgets('renders large size with appropriate font', (tester) async {
      await tester.pumpObers(
        const OiPriceTag(price: 10, label: 'Price', size: OiPriceTagSize.large),
      );
      final textWidget = tester.widget<Text>(find.text(r'$10.00'));
      expect(textWidget.style?.fontSize, 20);
    });

    testWidgets('uses currencySymbol override when provided', (tester) async {
      await tester.pumpObers(
        const OiPriceTag(
          price: 99.99,
          label: 'Price',
          currencySymbol: '!!',
          currencyCode: 'USD',
        ),
      );
      expect(find.text('!!99.99'), findsOneWidget);
    });

    testWidgets('compare-at price uses textMuted color', (tester) async {
      await tester.pumpObers(
        const OiPriceTag(price: 29.99, label: 'Price', compareAtPrice: 59.99),
      );
      final context = tester.element(find.byType(OiPriceTag));
      final textMutedColor = OiTheme.of(context).colors.textMuted;
      final compareWidget = tester.widget<Text>(find.text(r'$59.99'));
      expect(compareWidget.style?.color, equals(textMutedColor));
    });

    testWidgets('accessibility: semantics announces label', (tester) async {
      await tester.pumpObers(
        const OiPriceTag(price: 42.99, label: 'Product price 42.99 USD'),
      );
      expect(find.bySemanticsLabel('Product price 42.99 USD'), findsOneWidget);
    });
  });
}
