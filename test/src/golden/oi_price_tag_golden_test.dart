// Golden tests have no public API.
// ignore_for_file: public_member_api_docs

import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/golden_helper.dart';

void main() {
  // ── OiPriceTag ────────────────────────────────────────────────────────────

  testGoldens('OiPriceTag variants — light', (tester) async {
    final builder = obersGoldenBuilder(
      columns: 3,
      children: {
        'Normal price': const OiPriceTag(price: 42.99, label: 'Normal price'),
        'Sale price': const OiPriceTag(
          price: 29.99,
          label: 'Sale price',
          compareAtPrice: 59.99,
        ),
        'Free': const OiPriceTag(price: 0, label: 'Free item'),
        'Negative': const OiPriceTag(price: -5, label: 'Discount'),
        'EUR after': const OiPriceTag(
          price: 19.99,
          label: 'Euro price',
          currencyCode: 'EUR',
        ),
        'Small': const OiPriceTag(
          price: 9.99,
          label: 'Small price',
          size: OiPriceTagSize.small,
        ),
        'Large': const OiPriceTag(
          price: 99.99,
          label: 'Large price',
          size: OiPriceTagSize.large,
        ),
        'No decimals': const OiPriceTag(
          price: 100,
          label: 'Whole price',
          decimalPlaces: 0,
        ),
      },
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'oi_price_tag_variants_light');
  });

  testGoldens('OiPriceTag variants — dark', (tester) async {
    final builder = obersGoldenBuilder(
      columns: 3,
      theme: OiThemeData.dark(),
      children: {
        'Normal price': const OiPriceTag(price: 42.99, label: 'Normal price'),
        'Sale price': const OiPriceTag(
          price: 29.99,
          label: 'Sale price',
          compareAtPrice: 59.99,
        ),
        'Free': const OiPriceTag(price: 0, label: 'Free item'),
        'Negative': const OiPriceTag(price: -5, label: 'Discount'),
        'EUR after': const OiPriceTag(
          price: 19.99,
          label: 'Euro price',
          currencyCode: 'EUR',
        ),
        'Small': const OiPriceTag(
          price: 9.99,
          label: 'Small price',
          size: OiPriceTagSize.small,
        ),
        'Large': const OiPriceTag(
          price: 99.99,
          label: 'Large price',
          size: OiPriceTagSize.large,
        ),
        'No decimals': const OiPriceTag(
          price: 100,
          label: 'Whole price',
          decimalPlaces: 0,
        ),
      },
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'oi_price_tag_variants_dark');
  });
}
