// Tests do not require documentation comments.

import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── OiSwitchTile ──────────────────────────────────────────────────────────

  group('OiSwitchTile', () {
    testWidgets('renders title and switch', (tester) async {
      await tester.pumpObers(
        OiSwitchTile(
          title: 'Dark Mode',
          value: false,
          onChanged: (_) {},
        ),
      );

      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.byType(OiSwitch), findsOneWidget);
    });

    testWidgets('tapping tile toggles value', (tester) async {
      bool? result;
      await tester.pumpObers(
        OiSwitchTile(
          title: 'Notifications',
          value: false,
          onChanged: (v) => result = v,
        ),
      );

      await tester.tap(find.text('Notifications'));
      await tester.pump();

      expect(result, isTrue);
    });

    testWidgets('disabled state prevents toggle', (tester) async {
      bool? result;
      await tester.pumpObers(
        OiSwitchTile(
          title: 'Locked',
          value: false,
          onChanged: (v) => result = v,
          enabled: false,
        ),
      );

      await tester.tap(find.text('Locked'), warnIfMissed: false);
      await tester.pump();

      expect(result, isNull);
    });
  });

  // ── OiCheckboxTile ────────────────────────────────────────────────────────

  group('OiCheckboxTile', () {
    testWidgets('renders title and checkbox', (tester) async {
      await tester.pumpObers(
        OiCheckboxTile(
          title: 'Accept Terms',
          value: false,
          onChanged: (_) {},
        ),
      );

      expect(find.text('Accept Terms'), findsOneWidget);
      expect(find.byType(OiCheckbox), findsOneWidget);
    });

    testWidgets('tapping tile toggles checkbox', (tester) async {
      bool? result;
      await tester.pumpObers(
        OiCheckboxTile(
          title: 'Agree',
          value: false,
          onChanged: (v) => result = v,
        ),
      );

      await tester.tap(find.text('Agree'));
      await tester.pump();

      expect(result, isTrue);
    });

    testWidgets('disabled state prevents toggle', (tester) async {
      bool? result;
      await tester.pumpObers(
        OiCheckboxTile(
          title: 'Locked',
          value: false,
          onChanged: (v) => result = v,
          enabled: false,
        ),
      );

      await tester.tap(find.text('Locked'), warnIfMissed: false);
      await tester.pump();

      expect(result, isNull);
    });
  });

  // ── OiRadioTile ───────────────────────────────────────────────────────────

  group('OiRadioTile', () {
    testWidgets('renders title and radio', (tester) async {
      await tester.pumpObers(
        OiRadioTile<String>(
          title: 'Option A',
          value: 'a',
          groupValue: null,
          onChanged: (_) {},
        ),
      );

      expect(find.text('Option A'), findsOneWidget);
      expect(find.byType(OiRadio<String>), findsOneWidget);
    });

    testWidgets('tapping tile selects value', (tester) async {
      String? result;
      await tester.pumpObers(
        OiRadioTile<String>(
          title: 'Option B',
          value: 'b',
          groupValue: 'a',
          onChanged: (v) => result = v,
        ),
      );

      await tester.tap(find.text('Option B'));
      await tester.pump();

      expect(result, 'b');
    });

    testWidgets('disabled state prevents selection', (tester) async {
      String? result;
      await tester.pumpObers(
        OiRadioTile<String>(
          title: 'Disabled Option',
          value: 'c',
          groupValue: 'a',
          onChanged: (v) => result = v,
          enabled: false,
        ),
      );

      await tester.tap(find.text('Disabled Option'), warnIfMissed: false);
      await tester.pump();

      expect(result, isNull);
    });
  });

  group('semantics', () {
    // A tile is one node for screen readers; its switch / box / radio is only
    // its picture, so nothing inside announces a second state.
    int statefulNodes(WidgetTester tester, Finder tile) {
      var count = 0;
      void visit(SemanticsNode node) {
        final data = node.getSemanticsData();
        final flags = data.flagsCollection;
        if (flags.isToggled != Tristate.none ||
            flags.isChecked != CheckedState.none) {
          count++;
        }
        node.visitChildren((child) {
          visit(child);
          return true;
        });
      }

      visit(tester.getSemantics(tile));
      return count;
    }

    testWidgets('OiSwitchTile is one toggled node', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpObers(
        OiSwitchTile(title: 'Notifications', value: true, onChanged: (_) {}),
      );

      expect(statefulNodes(tester, find.byType(OiSwitchTile)), 1);
      handle.dispose();
    });

    testWidgets('OiCheckboxTile is one checked node', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpObers(
        OiCheckboxTile(title: 'Terms', value: true, onChanged: (_) {}),
      );

      expect(statefulNodes(tester, find.byType(OiCheckboxTile)), 1);
      handle.dispose();
    });
  });
}
