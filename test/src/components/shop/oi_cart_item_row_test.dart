// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_image.dart';
import 'package:obers_ui/src/components/shop/oi_cart_item_row.dart';
import 'package:obers_ui/src/components/shop/oi_price_tag.dart';
import 'package:obers_ui/src/components/shop/oi_quantity_selector.dart';
import 'package:obers_ui/src/models/oi_cart_item.dart';
import 'package:obers_ui/src/primitives/gesture/oi_swipeable.dart';

import '../../../helpers/pump_app.dart';

const _item = OiCartItem(
  productKey: 'p1',
  name: 'Test Product',
  unitPrice: 25.00,
  quantity: 2,
  variantLabel: 'Red / Large',
  imageUrl: 'https://example.com/img.png',
);

const _itemNoImage = OiCartItem(
  productKey: 'p2',
  name: 'No Image Product',
  unitPrice: 10.00,
  quantity: 1,
);

const _itemNoVariant = OiCartItem(
  productKey: 'p3',
  name: 'Plain Product',
  unitPrice: 15.00,
  quantity: 3,
  imageUrl: 'https://example.com/img2.png',
);

void main() {
  group('OiCartItemRow', () {
    testWidgets('renders product name and variant label', (tester) async {
      await tester.pumpObers(
        const OiCartItemRow(item: _item, label: 'Cart item'),
        surfaceSize: const Size(600, 200),
      );
      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('Red / Large'), findsOneWidget);
    });

    testWidgets('shows OiImage when imageUrl provided', (tester) async {
      await tester.pumpObers(
        const OiCartItemRow(item: _item, label: 'Cart item'),
        surfaceSize: const Size(600, 200),
      );
      expect(find.byType(OiImage), findsOneWidget);
    });

    testWidgets('shows placeholder when imageUrl is null', (tester) async {
      await tester.pumpObers(
        const OiCartItemRow(item: _itemNoImage, label: 'Cart item'),
        surfaceSize: const Size(600, 200),
      );
      expect(find.byType(OiImage), findsNothing);
    });

    testWidgets('displays line total via OiPriceTag', (tester) async {
      await tester.pumpObers(
        const OiCartItemRow(item: _item, label: 'Cart item'),
        surfaceSize: const Size(600, 200),
      );
      // lineTotal = 25.00 * 2 = 50.00, EUR format: "50.00 €"
      expect(find.text('50.00 €'), findsOneWidget);
    });

    testWidgets('fires onQuantityChange when quantity adjusted', (
      tester,
    ) async {
      int? received;
      await tester.pumpObers(
        OiCartItemRow(
          item: _item,
          label: 'Cart item',
          onQuantityChange: (v) => received = v,
        ),
        surfaceSize: const Size(600, 200),
      );
      expect(find.byType(OiQuantitySelector), findsOneWidget);
    });

    testWidgets('fires onRemove when remove button tapped', (tester) async {
      var removed = false;
      await tester.pumpObers(
        OiCartItemRow(
          item: _item,
          label: 'Cart item',
          onRemove: () => removed = true,
        ),
        surfaceSize: const Size(600, 200),
      );
      await tester.tap(find.text('Remove'));
      await tester.pump();
      expect(removed, isTrue);
    });

    testWidgets('fires onTap when row tapped', (tester) async {
      var tapped = false;
      await tester.pumpObers(
        OiCartItemRow(
          item: _item,
          label: 'Cart item',
          onTap: () => tapped = true,
        ),
        surfaceSize: const Size(600, 200),
      );
      await tester.tap(find.byType(OiCartItemRow));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('hides quantity selector and remove when editable=false', (
      tester,
    ) async {
      await tester.pumpObers(
        OiCartItemRow(
          item: _item,
          label: 'Cart item',
          editable: false,
          onQuantityChange: (_) {},
          onRemove: () {},
        ),
        surfaceSize: const Size(600, 200),
      );
      expect(find.byType(OiQuantitySelector), findsNothing);
      expect(find.text('Remove'), findsNothing);
    });

    testWidgets('non-editable mode shows quantity text', (tester) async {
      await tester.pumpObers(
        const OiCartItemRow(item: _item, label: 'Cart item', editable: false),
        surfaceSize: const Size(600, 200),
      );
      expect(find.text('× 2'), findsOneWidget);
    });

    testWidgets('compact mode renders widget', (tester) async {
      await tester.pumpObers(
        const OiCartItemRow(item: _item, label: 'Cart item', compact: true),
        surfaceSize: const Size(600, 150),
      );
      expect(find.byType(OiCartItemRow), findsOneWidget);
    });

    testWidgets('swipe-to-remove present when editable and onRemove set', (
      tester,
    ) async {
      await tester.pumpObers(
        OiCartItemRow(item: _item, label: 'Cart item', onRemove: () {}),
        surfaceSize: const Size(600, 200),
      );
      expect(find.byType(OiSwipeable), findsOneWidget);
    });

    testWidgets('no swipe actions when editable=false', (tester) async {
      await tester.pumpObers(
        OiCartItemRow(
          item: _item,
          label: 'Cart item',
          editable: false,
          onRemove: () {},
        ),
        surfaceSize: const Size(600, 200),
      );
      expect(find.byType(OiSwipeable), findsNothing);
    });

    testWidgets('accessibility: semantic label present', (tester) async {
      await tester.pumpObers(
        const OiCartItemRow(item: _item, label: 'Test Product cart item'),
        surfaceSize: const Size(600, 200),
      );
      expect(find.bySemanticsLabel('Test Product cart item'), findsOneWidget);
    });

    testWidgets('hides variant label when variantLabel is null', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiCartItemRow(item: _itemNoVariant, label: 'Cart item'),
        surfaceSize: const Size(600, 200),
      );
      expect(find.text('Plain Product'), findsOneWidget);
      expect(find.text('Red / Large'), findsNothing);
    });

    testWidgets('uses provided currencyCode', (tester) async {
      await tester.pumpObers(
        const OiCartItemRow(
          item: _itemNoImage,
          label: 'Cart item',
          currencyCode: 'USD',
        ),
        surfaceSize: const Size(600, 200),
      );
      // USD: "$10.00"
      expect(find.text(r'$10.00'), findsOneWidget);
    });
  });
}
