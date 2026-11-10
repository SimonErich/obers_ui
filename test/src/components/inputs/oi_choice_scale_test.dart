import 'dart:ui' show CheckedState, SemanticsRole;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('arrows skip disabled choices and End selects the last choice', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var selected = 0;
    await tester.pumpObers(
      StatefulBuilder(
        builder: (context, setState) => Center(
          child: SizedBox(
            width: 342,
            child: OiChoiceScale<int>(
              label: 'Intensity',
              value: selected,
              options: const [
                OiChoiceScaleOption(value: 0, label: 'Soft'),
                OiChoiceScaleOption(
                  value: 1,
                  label: 'Unavailable',
                  enabled: false,
                ),
                OiChoiceScaleOption(value: 2, label: 'Strong'),
                OiChoiceScaleOption(value: 3, label: 'Maximum'),
              ],
              onChanged: (value) => setState(() => selected = value),
            ),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(selected, 2);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pump();
    expect(selected, 3);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(selected, 2);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(selected, 3);
    final node = tester.getSemantics(find.bySemanticsLabel('Maximum'));
    expect(
      tester.getSemantics(find.bySemanticsLabel('Intensity')).role,
      SemanticsRole.radioGroup,
    );
    expect(node.flagsCollection.isChecked, CheckedState.isTrue);
    semantics.dispose();
  });

  testWidgets('RTL arrows follow reading direction and large labels reflow', (
    tester,
  ) async {
    var selected = 0;
    await tester.pumpObers(
      StatefulBuilder(
        builder: (context, setState) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Center(
              child: SizedBox(
                width: 240,
                child: OiChoiceScale<int>(
                  label: 'Stimmung',
                  value: selected,
                  options: const [
                    OiChoiceScaleOption(value: 0, label: 'Ganz entspannt'),
                    OiChoiceScaleOption(value: 1, label: 'Sehr lebendig'),
                    OiChoiceScaleOption(value: 2, label: 'Ausgelassen'),
                  ],
                  onChanged: (value) => setState(() => selected = value),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(selected, 1);
    expect(tester.takeException(), isNull);
    expect(find.byType(Wrap), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pump();
    expect(selected, 0);
  });

  testWidgets('a disabled group cannot change through pointer or keyboard', (
    tester,
  ) async {
    await tester.pumpObers(
      const Center(
        child: SizedBox(
          width: 240,
          child: OiChoiceScale<int>(
            label: 'Intensity',
            value: 0,
            options: [
              OiChoiceScaleOption(value: 0, label: 'Low'),
              OiChoiceScaleOption(value: 1, label: 'High'),
            ],
            onChanged: null,
          ),
        ),
      ),
    );
    await tester.tap(find.text('High'));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(
      tester.widget<OiChoiceScale<int>>(find.byType(OiChoiceScale<int>)).value,
      0,
    );
  });
}
