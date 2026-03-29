// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/navigation/oi_status_bar.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiStatusBar', () {
    testWidgets('renders leading and trailing widgets', (tester) async {
      await tester.pumpObers(
        const OiStatusBar(
          label: 'status',
          leading: [OiStatusBarItem(label: 'UTF-8')],
          trailing: [OiStatusBarItem(label: 'Ln 42')],
        ),
      );
      expect(find.text('UTF-8'), findsOneWidget);
      expect(find.text('Ln 42'), findsOneWidget);
    });

    testWidgets('renders empty bar without items', (tester) async {
      await tester.pumpObers(const OiStatusBar(label: 'status'));
      expect(find.byType(OiStatusBar), findsOneWidget);
    });

    testWidgets('height constraint is respected', (tester) async {
      await tester.pumpObers(const OiStatusBar(label: 'status', height: 30));
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(OiStatusBar),
          matching: find.byType(Container),
        ),
      );
      expect(container.constraints?.maxHeight, 30);
    });

    testWidgets('has semantics label', (tester) async {
      await tester.pumpObers(const OiStatusBar(label: 'App Status'));
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'App Status',
        ),
        findsOneWidget,
      );
    });

    testWidgets('applies custom background color', (tester) async {
      const customColor = Color(0xFF112233);
      await tester.pumpObers(
        const OiStatusBar(label: 'status', backgroundColor: customColor),
      );
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(OiStatusBar),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, customColor);
    });
  });

  group('OiStatusBarItem', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpObers(
        const OiStatusBar(
          label: 'status',
          leading: [OiStatusBarItem(label: 'Ready')],
        ),
      );
      expect(find.text('Ready'), findsOneWidget);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpObers(
        const OiStatusBar(
          label: 'status',
          leading: [OiStatusBarItem(label: 'Test', icon: IconData(0xe800))],
        ),
      );
      expect(find.byType(OiIcon), findsOneWidget);
    });

    testWidgets('renders color dot when color provided', (tester) async {
      await tester.pumpObers(
        const OiStatusBar(
          label: 'status',
          leading: [
            OiStatusBarItem(label: 'Connected', color: Color(0xFF00FF00)),
          ],
        ),
      );
      // The status dot is a 6x6 Container with a circle decoration.
      final dotFinder = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).shape == BoxShape.circle,
      );
      expect(dotFinder, findsOneWidget);
    });

    testWidgets('does not render color dot when color is null', (tester) async {
      await tester.pumpObers(
        const OiStatusBar(
          label: 'status',
          leading: [OiStatusBarItem(label: 'No dot')],
        ),
      );
      final dotFinder = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).shape == BoxShape.circle,
      );
      expect(dotFinder, findsNothing);
    });

    testWidgets('wraps in OiTappable when onTap is provided', (tester) async {
      await tester.pumpObers(
        OiStatusBar(
          label: 'status',
          leading: [OiStatusBarItem(label: 'Tap me', onTap: () {})],
        ),
      );
      expect(find.byType(OiTappable), findsOneWidget);
    });

    testWidgets('does not wrap in OiTappable when onTap is null', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiStatusBar(
          label: 'status',
          leading: [OiStatusBarItem(label: 'Static')],
        ),
      );
      expect(find.byType(OiTappable), findsNothing);
    });

    testWidgets('onTap fires callback', (tester) async {
      var tapped = false;
      await tester.pumpObers(
        OiStatusBar(
          label: 'status',
          leading: [
            OiStatusBarItem(label: 'Tap me', onTap: () => tapped = true),
          ],
        ),
      );
      await tester.tap(find.byType(OiTappable));
      expect(tapped, isTrue);
    });
  });
}
