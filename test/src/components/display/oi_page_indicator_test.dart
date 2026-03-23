// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_page_indicator.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiPageIndicator', () {
    // ── Rendering ────────────────────────────────────────────────────────────

    testWidgets('renders correct number of dots', (tester) async {
      await tester.pumpObers(
        const OiPageIndicator(count: 5, current: 0),
      );
      expect(find.byType(AnimatedContainer), findsNWidgets(5));
    });

    testWidgets('renders one dot per page', (tester) async {
      await tester.pumpObers(
        const OiPageIndicator(count: 3, current: 2),
      );
      expect(find.byType(AnimatedContainer), findsNWidgets(3));
    });

    testWidgets('renders zero dots when count is 0', (tester) async {
      await tester.pumpObers(
        const OiPageIndicator(count: 0, current: 0),
      );
      expect(find.byType(AnimatedContainer), findsNothing);
    });

    // ── Active dot styling ───────────────────────────────────────────────────

    testWidgets('active dot has different color from inactive dots', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiPageIndicator(count: 3, current: 1),
      );
      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decorations = containers.map((c) {
        return (c.decoration! as BoxDecoration).color;
      }).toList();

      // Active (index 1) should differ from inactive (index 0).
      expect(
        decorations[1],
        isNot(equals(decorations[0])),
        reason: 'Active dot should have a different color than inactive',
      );
    });

    // ── Pill variant ─────────────────────────────────────────────────────────

    testWidgets('pill variant renders wider active dot', (tester) async {
      await tester.pumpObers(
        const OiPageIndicator.pill(count: 3, current: 0),
      );
      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      ).toList();

      // The active pill dot should be wider than the inactive dot.
      // Active width = size * 2.5 = 20, inactive width = size = 8.
      final activeBox = tester.getSize(
        find.byWidget(containers[0]),
      );
      final inactiveBox = tester.getSize(
        find.byWidget(containers[1]),
      );
      expect(
        activeBox.width,
        greaterThan(inactiveBox.width),
        reason: 'Pill active dot should be wider than inactive dot',
      );
    });

    testWidgets('non-pill active dot has same width as inactive dot', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiPageIndicator(count: 3, current: 0),
      );
      final containers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      ).toList();

      final activeBox = tester.getSize(find.byWidget(containers[0]));
      final inactiveBox = tester.getSize(find.byWidget(containers[1]));
      expect(
        activeBox.width,
        equals(inactiveBox.width),
        reason: 'Non-pill active dot should have the same width as inactive',
      );
    });

    // ── Semantics ────────────────────────────────────────────────────────────

    testWidgets('default semantics announces page N of M', (tester) async {
      await tester.pumpObers(
        const OiPageIndicator(count: 5, current: 2),
      );
      // current=2 → "Page 3 of 5"
      expect(find.bySemanticsLabel('Page 3 of 5'), findsOneWidget);
    });

    testWidgets('custom semanticLabel overrides default', (tester) async {
      await tester.pumpObers(
        const OiPageIndicator(
          count: 3,
          current: 0,
          semanticLabel: 'Step indicator',
        ),
      );
      expect(find.bySemanticsLabel('Step indicator'), findsOneWidget);
    });
  });
}
