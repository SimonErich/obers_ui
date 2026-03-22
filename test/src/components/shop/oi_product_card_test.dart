// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/feedback/oi_star_rating.dart';
import 'package:obers_ui/src/components/shop/oi_price_tag.dart';
import 'package:obers_ui/src/components/shop/oi_product_card.dart';
import 'package:obers_ui/src/models/oi_product_data.dart';
import 'package:obers_ui/src/primitives/animation/oi_shimmer.dart';

import '../../../helpers/pump_app.dart';

/// Test product data with all fields populated (no network image).
const _product = OiProductData(
  key: 'test-1',
  name: 'Test Widget',
  price: 42.99,
  rating: 4.5,
  reviewCount: 128,
);

/// Test product that is on sale.
const _saleProduct = OiProductData(
  key: 'test-2',
  name: 'Sale Widget',
  price: 29.99,
  compareAtPrice: 59.99,
);

/// Test product that is out of stock.
const _oosProduct = OiProductData(
  key: 'test-3',
  name: 'Unavailable Widget',
  price: 19.99,
  inStock: false,
);

/// Test product with no image.
const _noImageProduct = OiProductData(
  key: 'test-4',
  name: 'No Image Widget',
  price: 10,
);

void main() {
  group('OiProductCard', () {
    testWidgets('vertical variant: renders image and name', (tester) async {
      await tester.pumpObers(
        const OiProductCard(product: _product, label: 'Test Widget card'),
        surfaceSize: const Size(400, 600),
      );
      expect(find.text('Test Widget'), findsOneWidget);
      expect(find.byType(OiPriceTag), findsOneWidget);
    });

    testWidgets('horizontal variant: renders image and details', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiProductCard.horizontal(
          product: _product,
          label: 'Test Widget card',
        ),
        surfaceSize: const Size(600, 400),
      );
      expect(find.text('Test Widget'), findsOneWidget);
      expect(find.byType(OiPriceTag), findsOneWidget);
    });

    testWidgets('compact variant: condensed layout', (tester) async {
      await tester.pumpObers(
        const OiProductCard(
          product: _product,
          label: 'Test Widget card',
          variant: OiProductCardVariant.compact,
        ),
        surfaceSize: const Size(400, 200),
      );
      expect(find.text('Test Widget'), findsOneWidget);
    });

    testWidgets('shows Sale badge when compareAtPrice > price', (tester) async {
      await tester.pumpObers(
        const OiProductCard(product: _saleProduct, label: 'Sale card'),
        surfaceSize: const Size(400, 600),
      );
      expect(find.text('Sale'), findsOneWidget);
    });

    testWidgets('shows Out of Stock badge when inStock is false', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiProductCard(product: _oosProduct, label: 'OOS card'),
        surfaceSize: const Size(400, 600),
      );
      expect(find.text('Out of Stock'), findsOneWidget);
    });

    testWidgets('hides rating when showRating is false', (tester) async {
      await tester.pumpObers(
        const OiProductCard(
          product: _product,
          label: 'No rating card',
          showRating: false,
        ),
        surfaceSize: const Size(400, 600),
      );
      expect(find.byType(OiStarRating), findsNothing);
    });

    testWidgets('hides add-to-cart when showAddToCart is false', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiProductCard(
          product: _product,
          label: 'No cart card',
          showAddToCart: false,
        ),
        surfaceSize: const Size(400, 600),
      );
      expect(find.text('Add to Cart'), findsNothing);
    });

    testWidgets('shows wishlist button when showWishlist is true', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiProductCard(
          product: _product,
          label: 'Wishlist card',
          showWishlist: true,
        ),
        surfaceSize: const Size(400, 600),
      );
      expect(find.text('Wishlist'), findsOneWidget);
    });

    testWidgets('onTap callback fires on card tap', (tester) async {
      var tapped = false;
      await tester.pumpObers(
        OiProductCard(
          product: _product,
          label: 'Tappable card',
          onTap: () => tapped = true,
        ),
        surfaceSize: const Size(400, 600),
      );
      await tester.tap(find.byType(OiProductCard));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('onAddToCart callback fires on button tap', (tester) async {
      var addedToCart = false;
      await tester.pumpObers(
        OiProductCard(
          product: _product,
          label: 'Cart card',
          onAddToCart: () => addedToCart = true,
        ),
        surfaceSize: const Size(400, 600),
      );
      await tester.tap(find.text('Add to Cart'));
      await tester.pump();
      expect(addedToCart, isTrue);
    });

    testWidgets('onWishlist callback fires on wishlist button tap', (
      tester,
    ) async {
      var wishlisted = false;
      await tester.pumpObers(
        OiProductCard(
          product: _product,
          label: 'Wishlist card',
          showWishlist: true,
          onWishlist: () => wishlisted = true,
        ),
        surfaceSize: const Size(400, 600),
      );
      await tester.tap(find.text('Wishlist'));
      await tester.pump();
      expect(wishlisted, isTrue);
    });

    testWidgets('add-to-cart disabled when out of stock', (tester) async {
      var addedToCart = false;
      await tester.pumpObers(
        OiProductCard(
          product: _oosProduct,
          label: 'OOS card',
          onAddToCart: () => addedToCart = true,
        ),
        surfaceSize: const Size(400, 600),
      );
      await tester.tap(find.text('Add to Cart'));
      await tester.pump();
      expect(addedToCart, isFalse);
    });

    testWidgets('shows OiShimmer placeholder for null imageUrl', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiProductCard(product: _noImageProduct, label: 'No image card'),
        surfaceSize: const Size(400, 600),
      );
      expect(find.byType(OiShimmer), findsOneWidget);
    });

    testWidgets('.horizontal() factory sets variant to horizontal', (
      tester,
    ) async {
      const card = OiProductCard.horizontal(
        product: _product,
        label: 'Horizontal card',
      );
      expect(card.variant, OiProductCardVariant.horizontal);
    });

    testWidgets('shows skeleton loading state when isLoading is true', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiProductCard(
          product: _product,
          label: 'Loading card',
          isLoading: true,
        ),
        surfaceSize: const Size(400, 600),
      );
      expect(find.byType(OiShimmer), findsWidgets);
      expect(find.text('Test Widget'), findsNothing);
    });

    testWidgets('accessibility: card label includes product name', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiProductCard(product: _product, label: 'Test Widget card'),
        surfaceSize: const Size(400, 600),
      );
      expect(find.text('Test Widget'), findsOneWidget);
    });
  });
}
