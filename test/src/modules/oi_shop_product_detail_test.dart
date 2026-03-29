// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/pump_app.dart';

// ── Test data helpers ────────────────────────────────────────────────────────

OiProductData _sampleProduct() =>
    const OiProductData(key: 'prod-1', name: 'Test Widget', price: 49.99);

OiProductData _outOfStockProduct() => const OiProductData(
  key: 'prod-2',
  name: 'Sold Out Widget',
  price: 29.99,
  inStock: false,
);

OiProductData _productWithVariants() => const OiProductData(
  key: 'prod-3',
  name: 'Variant Widget',
  price: 39.99,
  variants: [
    OiProductVariant(key: 'v1', label: 'Small', price: 39.99),
    OiProductVariant(key: 'v2', label: 'Large', price: 49.99),
  ],
);

void main() {
  group('OiShopProductDetail', () {
    testWidgets('renders product name and price', (tester) async {
      await tester.pumpObers(
        OiShopProductDetail(product: _sampleProduct(), label: 'Product detail'),
        surfaceSize: const Size(1200, 800),
      );

      expect(find.text('Test Widget'), findsOneWidget);
      // Price tag should contain the price value.
      expect(find.byType(OiPriceTag), findsWidgets);
    });

    testWidgets('renders quantity selector', (tester) async {
      await tester.pumpObers(
        OiShopProductDetail(product: _sampleProduct(), label: 'Product detail'),
        surfaceSize: const Size(1200, 800),
      );

      expect(find.byType(OiQuantitySelector), findsOneWidget);
    });

    testWidgets('invokes onAddToCart callback', (tester) async {
      OiCartItem? capturedItem;

      await tester.pumpObers(
        OiShopProductDetail(
          product: _sampleProduct(),
          label: 'Product detail',
          onAddToCart: (item) => capturedItem = item,
        ),
        surfaceSize: const Size(1200, 800),
      );

      // Tap the "Add to Cart" button.
      await tester.tap(find.text('Add to Cart'));
      await tester.pumpAndSettle();

      expect(capturedItem, isNotNull);
      expect(capturedItem!.productKey, 'prod-1');
      expect(capturedItem!.unitPrice, 49.99);
      expect(capturedItem!.quantity, 1);
    });

    testWidgets('disables Add to Cart for out-of-stock product', (
      tester,
    ) async {
      OiCartItem? capturedItem;

      await tester.pumpObers(
        OiShopProductDetail(
          product: _outOfStockProduct(),
          label: 'Product detail',
          onAddToCart: (item) => capturedItem = item,
        ),
        surfaceSize: const Size(1200, 800),
      );

      // Out-of-stock badge should be visible.
      expect(find.text('Out of Stock'), findsOneWidget);

      // Tap Add to Cart — should be disabled.
      await tester.tap(find.text('Add to Cart'));
      await tester.pumpAndSettle();

      expect(capturedItem, isNull);
    });

    testWidgets('displays gallery placeholder when no images', (tester) async {
      await tester.pumpObers(
        OiShopProductDetail(product: _sampleProduct(), label: 'Product detail'),
        surfaceSize: const Size(1200, 800),
      );

      expect(find.text('No image available'), findsOneWidget);
    });

    testWidgets('renders description tab when provided', (tester) async {
      await tester.pumpObers(
        OiShopProductDetail(
          product: _sampleProduct(),
          label: 'Product detail',
          description: const Text('A detailed description'),
        ),
        surfaceSize: const Size(1200, 800),
      );

      expect(find.text('Description'), findsOneWidget);
      expect(find.text('A detailed description'), findsOneWidget);
    });

    testWidgets('renders mobile layout at small breakpoint', (tester) async {
      await tester.pumpObers(
        OiShopProductDetail(product: _sampleProduct(), label: 'Product detail'),
        surfaceSize: const Size(400, 800),
      );

      expect(find.text('Test Widget'), findsOneWidget);
    });

    testWidgets('shows variant selector when product has variants', (
      tester,
    ) async {
      await tester.pumpObers(
        OiShopProductDetail(
          product: _productWithVariants(),
          label: 'Product detail',
        ),
        surfaceSize: const Size(1200, 800),
      );

      expect(find.text('Variant Widget'), findsOneWidget);
      expect(find.byType(OiSelect<Object>), findsOneWidget);
    });

    testWidgets('invokes onWishlist callback', (tester) async {
      var wishlistTapped = false;

      await tester.pumpObers(
        OiShopProductDetail(
          product: _sampleProduct(),
          label: 'Product detail',
          onWishlist: () => wishlistTapped = true,
        ),
        surfaceSize: const Size(1200, 800),
      );

      await tester.tap(find.text('Wishlist'));
      await tester.pumpAndSettle();

      expect(wishlistTapped, isTrue);
    });

    testWidgets('renders related products section', (tester) async {
      final related = [
        const OiProductData(key: 'rel-1', name: 'Related A', price: 19.99),
      ];

      await tester.pumpObers(
        OiShopProductDetail(
          product: _sampleProduct(),
          label: 'Product detail',
          related: related,
        ),
        surfaceSize: const Size(1200, 800),
      );

      expect(find.text('Related Products'), findsOneWidget);
    });
  });
}
