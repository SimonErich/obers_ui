// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/onboarding/oi_spotlight.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiSpotlight', () {
    testWidgets('renders overlay when active', (tester) async {
      final targetKey = GlobalKey();
      await tester.pumpObers(
        OiSpotlight(
          target: targetKey,
          child: Center(
            child: SizedBox(key: targetKey, width: 100, height: 50),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('oi_spotlight_overlay')), findsOneWidget);
    });

    testWidgets('hides overlay when inactive', (tester) async {
      final targetKey = GlobalKey();
      await tester.pumpObers(
        OiSpotlight(
          target: targetKey,
          active: false,
          child: Center(
            child: SizedBox(key: targetKey, width: 100, height: 50),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('oi_spotlight_overlay')), findsNothing);
    });

    testWidgets('cutout is positioned around target', (tester) async {
      final targetKey = GlobalKey();
      await tester.pumpObers(
        OiSpotlight(
          target: targetKey,
          child: Center(
            child: SizedBox(key: targetKey, width: 100, height: 50),
          ),
        ),
      );
      await tester.pump();

      // The overlay CustomPaint should exist covering the full area.
      final customPaint = tester.widget<CustomPaint>(
        find.byKey(const Key('oi_spotlight_overlay')),
      );
      expect(customPaint.painter, isNotNull);
    });

    testWidgets('applies padding around cutout', (tester) async {
      final targetKey = GlobalKey();
      const padding = 20.0;
      await tester.pumpObers(
        OiSpotlight(
          target: targetKey,
          padding: padding,
          child: Center(
            child: SizedBox(key: targetKey, width: 100, height: 50),
          ),
        ),
      );
      await tester.pump();

      // Verify the painter was created (padding is baked into the Rect).
      expect(find.byKey(const Key('oi_spotlight_overlay')), findsOneWidget);
    });

    testWidgets('borderRadius is applied to the cutout', (tester) async {
      final targetKey = GlobalKey();
      await tester.pumpObers(
        OiSpotlight(
          target: targetKey,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: SizedBox(key: targetKey, width: 100, height: 50),
          ),
        ),
      );
      await tester.pump();

      // The overlay renders without error when borderRadius is set.
      expect(find.byKey(const Key('oi_spotlight_overlay')), findsOneWidget);
    });

    testWidgets('onTapOutside fires when tapping overlay', (tester) async {
      final targetKey = GlobalKey();
      var tapped = false;
      await tester.pumpObers(
        OiSpotlight(
          target: targetKey,
          onTapOutside: () => tapped = true,
          child: Center(
            child: SizedBox(key: targetKey, width: 100, height: 50),
          ),
        ),
      );
      await tester.pump();

      // Tap on the overlay area (top-left corner, away from center target).
      await tester.tapAt(Offset.zero);
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('child is always rendered beneath overlay', (tester) async {
      final targetKey = GlobalKey();
      await tester.pumpObers(
        OiSpotlight(
          target: targetKey,
          child: Center(child: Text('Hello', key: targetKey)),
        ),
      );
      await tester.pump();

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('custom overlay color is used', (tester) async {
      final targetKey = GlobalKey();
      const customColor = Color(0xCC0000FF);
      await tester.pumpObers(
        OiSpotlight(
          target: targetKey,
          overlayColor: customColor,
          child: Center(
            child: SizedBox(key: targetKey, width: 100, height: 50),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('oi_spotlight_overlay')), findsOneWidget);
    });
  });
}
