import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('sheet can retain the caller focus until explicitly entered', (
    tester,
  ) async {
    final caller = FocusNode();
    final field = FocusNode();
    addTearDown(caller.dispose);
    addTearDown(field.dispose);
    await tester.pumpObers(
      Focus(focusNode: caller, child: const Text('Caller')),
    );
    caller.requestFocus();
    await tester.pump();
    await tester.pumpObers(
      Stack(
        children: [
          Focus(focusNode: caller, child: const Text('Caller')),
          OiSheet(
            label: 'Details',
            open: true,
            initialFocus: false,
            child: Focus(focusNode: field, child: const Text('Field')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(caller.hasPrimaryFocus, isTrue);
    expect(field.hasFocus, isFalse);
    field.requestFocus();
    await tester.pump();
    expect(field.hasPrimaryFocus, isTrue);
  });

  testWidgets('localized wizard controls still navigate and complete', (
    tester,
  ) async {
    var completed = false;
    await tester.pumpObers(
      SizedBox(
        width: 500,
        height: 500,
        child: OiWizard(
          labels: const OiWizardLabels(
            next: 'Weiter',
            previous: 'Zurück',
            complete: 'Fertig',
            cancel: 'Abbrechen',
          ),
          steps: [
            OiWizardStep(
              title: 'Eins',
              builder: (_) => const Text('Erster Schritt'),
            ),
            OiWizardStep(
              title: 'Zwei',
              builder: (_) => const Text('Zweiter Schritt'),
            ),
          ],
          showSummary: false,
          onComplete: (_) => completed = true,
        ),
      ),
    );
    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();
    expect(find.text('Zweiter Schritt'), findsOneWidget);
    await tester.tap(find.text('Zurück'));
    await tester.pumpAndSettle();
    expect(find.text('Erster Schritt'), findsOneWidget);
    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fertig'));
    await tester.pumpAndSettle();
    expect(completed, isTrue);
  });

  testWidgets(
    'externally timed toast pauses on hover and remains dismissible',
    (
      tester,
    ) async {
      var paused = 0;
      var resumed = 0;
      var dismissed = 0;
      await tester.pumpObers(
        Center(
          child: OiToast(
            label: 'Save status',
            message: 'Saved',
            duration: null,
            dismissLabel: 'Schließen',
            onPauseRequested: () => paused++,
            onResumeRequested: () => resumed++,
            onDismiss: () => dismissed++,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byType(OiToast)));
      await tester.pump();
      expect(paused, 1);
      await mouse.moveTo(Offset.zero);
      await tester.pump();
      expect(resumed, 1);
      await tester.pump(const Duration(seconds: 20));
      expect(dismissed, 0);
      await tester.tap(find.bySemanticsLabel('Schließen'));
      await tester.pumpAndSettle();
      expect(dismissed, 1);
      await mouse.removePointer();
    },
  );

  testWidgets('raw max length limits graphemes after caller formatters', (
    tester,
  ) async {
    final controller = TextEditingController();
    final focus = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    await tester.pumpObers(
      OiRawInput(
        controller: controller,
        focusNode: focus,
        maxLength: 2,
        inputFormatters: [FilteringTextInputFormatter.deny(RegExp('[0-9]'))],
      ),
    );
    await tester.enterText(find.byType(EditableText), '1👩‍👩‍👧‍👦a2b');
    expect(controller.text, '👩‍👩‍👧‍👦a');
  });

  testWidgets('quantity suffix preserves bounds and named controls', (
    tester,
  ) async {
    int? changed;
    await tester.pumpObers(
      Center(
        child: OiQuantitySelector(
          value: 2,
          min: 2,
          max: 3,
          label: 'Soup portions',
          suffix: 'Portionen',
          increaseLabel: 'Add soup portion',
          onChange: (value) => changed = value,
        ),
      ),
    );
    expect(find.text('Portionen'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Add soup portion'));
    await tester.pump();
    expect(changed, 3);
  });
}
