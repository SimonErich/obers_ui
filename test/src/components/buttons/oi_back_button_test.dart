// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_back_button.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiBackButton', () {
    // ── Rendering ────────────────────────────────────────────────────────────

    testWidgets('renders without error', (tester) async {
      await tester.pumpObers(
        OiBackButton(onPressed: () {}, semanticLabel: 'Go back'),
      );
      expect(find.byType(OiBackButton), findsOneWidget);
    });

    testWidgets('renders an Icon widget', (tester) async {
      await tester.pumpObers(
        OiBackButton(onPressed: () {}, semanticLabel: 'Go back'),
      );
      expect(find.byType(Icon), findsOneWidget);
    });

    // ── Interaction ──────────────────────────────────────────────────────────

    testWidgets('fires onPressed when tapped', (tester) async {
      var pressed = false;
      await tester.pumpObers(
        OiBackButton(onPressed: () => pressed = true, semanticLabel: 'Go back'),
      );
      await tester.tap(find.byType(OiBackButton));
      await tester.pump();
      expect(pressed, isTrue);
    });

    // ── Semantics ────────────────────────────────────────────────────────────

    testWidgets('semantic label "Go back" is applied', (tester) async {
      await tester.pumpObers(
        OiBackButton(onPressed: () {}, semanticLabel: 'Go back'),
      );
      expect(find.bySemanticsLabel('Go back'), findsOneWidget);
    });

    testWidgets('custom semantic label is applied', (tester) async {
      await tester.pumpObers(
        OiBackButton(onPressed: () {}, semanticLabel: 'Return'),
      );
      expect(find.bySemanticsLabel('Return'), findsOneWidget);
    });

    // ── Custom size ──────────────────────────────────────────────────────────

    testWidgets('custom size is applied to icon', (tester) async {
      await tester.pumpObers(
        OiBackButton(onPressed: () {}, semanticLabel: 'Go back', size: 32),
      );
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, 32);
    });

    testWidgets('default icon size is 24', (tester) async {
      await tester.pumpObers(
        OiBackButton(onPressed: () {}, semanticLabel: 'Go back'),
      );
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, 24);
    });

    // ── RTL ──────────────────────────────────────────────────────────────────

    testWidgets('uses different icon in RTL layout', (tester) async {
      // LTR icon.
      await tester.pumpObers(
        OiBackButton(onPressed: () {}, semanticLabel: 'Go back'),
      );
      final ltrIcon = tester.widget<Icon>(find.byType(Icon));
      final ltrIconData = ltrIcon.icon;

      // RTL icon.
      await tester.pumpObers(
        Directionality(
          textDirection: TextDirection.rtl,
          child: OiBackButton(onPressed: () {}, semanticLabel: 'Go back'),
        ),
      );
      final rtlIcon = tester.widget<Icon>(find.byType(Icon));
      final rtlIconData = rtlIcon.icon;

      expect(
        ltrIconData,
        isNot(equals(rtlIconData)),
        reason: 'RTL layout should flip the chevron direction',
      );
    });
  });
}
