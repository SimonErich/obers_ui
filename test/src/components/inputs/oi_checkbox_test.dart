// Tests do not require documentation comments.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_checkbox.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('rich labels retain a single named keyboard-operable checkbox', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var value = false;
    await tester.pumpObers(
      StatefulBuilder(
        builder: (context, setState) => OiCheckbox(
          value: value,
          semanticLabel: 'Extra cheese, 1.50',
          labelWidget: const Text('Extra cheese +1.50'),
          onChanged: (next) => setState(() => value = next),
        ),
      ),
    );
    await tester.tap(find.text('Extra cheese +1.50'));
    await tester.pump();
    expect(value, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(value, isFalse);
    expect(find.bySemanticsLabel('Extra cheese, 1.50'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('long checkbox labels wrap inside compact filter panels', (
    tester,
  ) async {
    const label = 'Needs attention before the next delivery window';
    await tester.pumpObers(
      Center(
        child: SizedBox(
          width: 140,
          child: OiCheckbox(value: false, label: label, onChanged: (_) {}),
        ),
      ),
    );
    final box = tester.getRect(find.byType(OiCheckbox));
    final text = tester.getRect(find.text(label));
    expect(text.right, lessThanOrEqualTo(box.right));
    expect(text.height, greaterThan(20));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'named mixed checkbox has checked semantics and keyboard activation',
    (tester) async {
      final semantics = tester.ensureSemantics();
      var value = false;
      var changes = 0;
      await tester.pumpObers(
        StatefulBuilder(
          builder: (context, setState) => OiCheckbox(
            value: value,
            semanticLabel: 'Select order',
            onChanged: (next) {
              setState(() => value = next);
              changes++;
            },
          ),
        ),
      );
      expect(
        tester.getSemantics(find.byType(OiCheckbox)),
        matchesSemantics(
          label: 'Select order',
          hasCheckedState: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(value, isTrue);
      expect(changes, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(value, isFalse);
      expect(changes, 2);
      await tester.pumpObers(
        OiCheckbox(
          value: null,
          semanticLabel: 'Select page',
          onChanged: (_) {},
        ),
      );
      expect(
        tester.getSemantics(find.byType(OiCheckbox)),
        matchesSemantics(
          label: 'Select page',
          hasCheckedState: true,
          isCheckStateMixed: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      semantics.dispose();
    },
  );

  testWidgets('disabled checkbox cannot receive focus or keyboard changes', (
    tester,
  ) async {
    var changed = false;
    await tester.pumpObers(
      OiCheckbox(
        value: false,
        enabled: false,
        onChanged: (_) => changed = true,
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(changed, isFalse);
    expect(
      tester
          .widget<FocusableActionDetector>(find.byType(FocusableActionDetector))
          .focusNode!
          .hasFocus,
      isFalse,
    );
  });

  testWidgets('renders unchecked state', (tester) async {
    await tester.pumpObers(const OiCheckbox(value: false));
    expect(find.byType(OiCheckbox), findsOneWidget);
  });

  testWidgets('renders checked state', (tester) async {
    await tester.pumpObers(const OiCheckbox(value: true));
    expect(find.byType(OiCheckbox), findsOneWidget);
  });

  testWidgets('renders indeterminate state', (tester) async {
    await tester.pumpObers(const OiCheckbox(value: null));
    expect(find.byType(OiCheckbox), findsOneWidget);
  });

  testWidgets('tapping unchecked fires onChanged with true', (tester) async {
    bool? result;
    await tester.pumpObers(
      OiCheckbox(value: false, onChanged: (v) => result = v),
    );
    await tester.tap(find.byType(OiCheckbox));
    await tester.pump();
    expect(result, isTrue);
  });

  testWidgets('tapping checked fires onChanged with false', (tester) async {
    bool? result;
    await tester.pumpObers(
      OiCheckbox(value: true, onChanged: (v) => result = v),
    );
    await tester.tap(find.byType(OiCheckbox));
    await tester.pump();
    expect(result, isFalse);
  });

  testWidgets('tapping indeterminate fires onChanged with true', (
    tester,
  ) async {
    bool? result;
    await tester.pumpObers(
      OiCheckbox(value: null, onChanged: (v) => result = v),
    );
    await tester.tap(find.byType(OiCheckbox));
    await tester.pump();
    expect(result, isTrue);
  });

  testWidgets('label is shown', (tester) async {
    await tester.pumpObers(
      const OiCheckbox(value: false, label: 'Accept terms'),
    );
    expect(find.text('Accept terms'), findsOneWidget);
  });

  testWidgets('enabled=false suppresses onChanged', (tester) async {
    bool? result;
    await tester.pumpObers(
      OiCheckbox(value: false, enabled: false, onChanged: (v) => result = v),
    );
    await tester.tap(find.byType(OiCheckbox), warnIfMissed: false);
    await tester.pump();
    expect(result, isNull);
  });
}
