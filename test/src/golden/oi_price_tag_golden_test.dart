// Golden tests have no public API.

import 'package:alchemist/alchemist.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/golden_helper.dart';

Future<void> main() async {
  // ── OiPriceTag ────────────────────────────────────────────────────────────

  await goldenTest(
    'OiPriceTag variants — light',
    fileName: 'oi_price_tag_variants_light',
    builder: () => obersGoldenGroup(
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
    ),
  );

  await goldenTest(
    'OiPriceTag variants — dark',
    fileName: 'oi_price_tag_variants_dark',
    builder: () => obersGoldenGroup(
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
    ),
  );
}
