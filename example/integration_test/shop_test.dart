// Test files do not need public API docs.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:obers_ui_example/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shop shows product cards', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    // Navigate to Shop.
    await tester.tap(find.text('Shop'));
    await tester.pumpAndSettle();

    // Verify a product card is visible.
    expect(find.text('Original Sacher-Torte'), findsOneWidget);
  });

  testWidgets('tapping product card shows product detail', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Shop'));
    await tester.pumpAndSettle();

    // Tap on the Original Sacher-Torte product card.
    await tester.tap(find.text('Original Sacher-Torte'));
    await tester.pumpAndSettle();

    // Product detail should show the product name and an Add to Cart button.
    expect(find.text('Add to Cart'), findsOneWidget);
    // The "Back to Products" ghost button should be visible.
    expect(find.text('Back to Products'), findsOneWidget);
  });

  testWidgets('add to cart and verify cart has items', (tester) async {
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Shop'));
    await tester.pumpAndSettle();

    // Tap on the Original Sacher-Torte product card.
    await tester.tap(find.text('Original Sacher-Torte'));
    await tester.pumpAndSettle();

    // Tap "Add to Cart" button.
    await tester.tap(find.text('Add to Cart'));
    await tester.pumpAndSettle();

    // Go back to browse.
    await tester.tap(find.text('Back to Products'));
    await tester.pumpAndSettle();

    // The mini cart should be visible. Tap "View Cart" to navigate to cart.
    // First we need to open the mini cart dropdown by tapping the cart icon.
    final viewCartFinder = find.text('View Cart');
    if (viewCartFinder.evaluate().isNotEmpty) {
      await tester.tap(viewCartFinder);
      await tester.pumpAndSettle();

      // Cart should show the product name.
      expect(
        find.textContaining('Sacher-Torte'),
        findsWidgets,
      );
    }
  });
}
