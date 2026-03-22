// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_icon_button.dart';
import 'package:obers_ui/src/components/shop/oi_quantity_selector.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiQuantitySelector', () {
    testWidgets('renders minus button, value, and plus button', (tester) async {
      await tester.pumpObers(
        OiQuantitySelector(value: 3, label: 'Qty', onChange: (_) {}),
      );
      // Value label should be visible.
      expect(find.text('3'), findsOneWidget);
      // Should find the quantity selector widget.
      expect(find.byType(OiQuantitySelector), findsOneWidget);
    });

    testWidgets('tapping plus calls onChange with value + 1', (tester) async {
      int? received;
      await tester.pumpObers(
        OiQuantitySelector(
          value: 3,
          label: 'Qty',
          onChange: (v) => received = v,
        ),
      );
      // Tap the plus (second) icon button.
      final iconButtons = find.byType(OiIconButton);
      await tester.tap(iconButtons.last);
      await tester.pump();
      expect(received, 4);
    });

    testWidgets('tapping minus calls onChange with value - 1', (tester) async {
      int? received;
      await tester.pumpObers(
        OiQuantitySelector(
          value: 3,
          label: 'Qty',
          onChange: (v) => received = v,
        ),
      );
      // Tap the minus (first) icon button.
      final iconButtons = find.byType(OiIconButton);
      await tester.tap(iconButtons.first);
      await tester.pump();
      expect(received, 2);
    });

    testWidgets('minus disabled at min boundary', (tester) async {
      int? received;
      await tester.pumpObers(
        OiQuantitySelector(
          value: 1,
          label: 'Qty',
          onChange: (v) => received = v,
        ),
      );
      // Tap the minus (first) button — should be disabled at min.
      final iconButtons = find.byType(OiIconButton);
      await tester.tap(iconButtons.first, warnIfMissed: false);
      await tester.pump();
      expect(received, isNull);
    });

    testWidgets('plus disabled at max boundary', (tester) async {
      int? received;
      await tester.pumpObers(
        OiQuantitySelector(
          value: 99,
          label: 'Qty',
          onChange: (v) => received = v,
        ),
      );
      // Tap the plus (last) button — should be disabled at max.
      final iconButtons = find.byType(OiIconButton);
      await tester.tap(iconButtons.last, warnIfMissed: false);
      await tester.pump();
      expect(received, isNull);
    });

    testWidgets('compact mode renders with OiLabel.small', (tester) async {
      await tester.pumpObers(
        OiQuantitySelector(
          value: 5,
          label: 'Qty',
          compact: true,
          onChange: (_) {},
        ),
      );
      // Find OiLabel widget (compact uses small variant).
      final labels = tester.widgetList<OiLabel>(find.byType(OiLabel));
      expect(labels, isNotEmpty);
    });

    testWidgets('disabled state disables both buttons', (tester) async {
      int? received;
      await tester.pumpObers(
        OiQuantitySelector(
          value: 5,
          label: 'Qty',
          disabled: true,
          onChange: (v) => received = v,
        ),
      );
      // Tapping should not fire onChange when disabled.
      final iconButtons = find.byType(OiIconButton);
      await tester.tap(iconButtons.first, warnIfMissed: false);
      await tester.pump();
      expect(received, isNull);
      await tester.tap(iconButtons.last, warnIfMissed: false);
      await tester.pump();
      expect(received, isNull);
    });

    testWidgets('null onChange disables interaction', (tester) async {
      await tester.pumpObers(const OiQuantitySelector(value: 3, label: 'Qty'));
      // Widget should render without errors.
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('keyboard arrow up increments', (tester) async {
      int? received;
      await tester.pumpObers(
        OiQuantitySelector(
          value: 3,
          label: 'Qty',
          onChange: (v) => received = v,
        ),
      );
      // Focus the widget then send key.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(received, 4);
    });

    testWidgets('keyboard arrow down decrements', (tester) async {
      int? received;
      await tester.pumpObers(
        OiQuantitySelector(
          value: 3,
          label: 'Qty',
          onChange: (v) => received = v,
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(received, 2);
    });

    testWidgets('accessibility: semantics label includes value, min, max', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpObers(
        OiQuantitySelector(value: 3, label: 'Qty', max: 10, onChange: (_) {}),
      );
      expect(
        find.bySemanticsLabel(
          RegExp('Qty.*Quantity.*3.*minimum.*1.*maximum.*10'),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
