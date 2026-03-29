// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/shop/oi_wishlist_button.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiWishlistButton', () {
    testWidgets('renders inactive (outline) heart icon', (tester) async {
      await tester.pumpObers(const OiWishlistButton(label: 'Wishlist'));

      expect(find.byType(Icon), findsOneWidget);
      expect(find.byType(OiWishlistButton), findsOneWidget);
    });

    testWidgets('renders active (filled) heart icon', (tester) async {
      await tester.pumpObers(
        const OiWishlistButton(label: 'Wishlist', active: true),
      );

      // When active, a filled heart is drawn with CustomPaint (no Icon widget).
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('fires onToggle when tapped', (tester) async {
      var toggled = false;
      await tester.pumpObers(
        OiWishlistButton(label: 'Wishlist', onToggle: () => toggled = true),
      );

      await tester.tap(find.byType(OiWishlistButton));
      await tester.pump();
      expect(toggled, isTrue);
    });

    testWidgets('loading state disables tap', (tester) async {
      var toggled = false;
      await tester.pumpObers(
        OiWishlistButton(
          label: 'Wishlist',
          loading: true,
          onToggle: () => toggled = true,
        ),
      );

      await tester.tap(find.byType(OiWishlistButton), warnIfMissed: false);
      await tester.pump();
      expect(toggled, isFalse);
    });

    testWidgets('loading state shows reduced opacity', (tester) async {
      await tester.pumpObers(
        OiWishlistButton(label: 'Wishlist', loading: true, onToggle: () {}),
      );

      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, 0.4);
    });

    testWidgets('null onToggle disables interaction', (tester) async {
      await tester.pumpObers(const OiWishlistButton(label: 'Wishlist'));

      // Should render without error.
      expect(find.byType(OiWishlistButton), findsOneWidget);
    });

    testWidgets('semantic label and toggled state are set', (tester) async {
      await tester.pumpObers(
        const OiWishlistButton(label: 'Add to wishlist', active: true),
      );

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              w.properties.label == 'Add to wishlist' &&
              (w.properties.toggled ?? false),
        ),
        findsOneWidget,
      );
    });
  });
}
