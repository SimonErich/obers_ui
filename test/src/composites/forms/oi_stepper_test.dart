// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/forms/oi_stepper.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _stepper({
  int totalSteps = 3,
  int currentStep = 0,
  List<String>? stepLabels,
  List<IconData>? stepIcons,
  OiStepperStyle style = OiStepperStyle.horizontal,
  ValueChanged<int>? onStepTap,
  Set<int> completedSteps = const {},
  Set<int> errorSteps = const {},
}) {
  return OiStepper(
    totalSteps: totalSteps,
    currentStep: currentStep,
    stepLabels: stepLabels,
    stepIcons: stepIcons,
    style: style,
    onStepTap: onStepTap,
    completedSteps: completedSteps,
    errorSteps: errorSteps,
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // 1. Renders the correct number of step circles
  testWidgets('renders the correct number of step circles', (tester) async {
    await tester.pumpObers(_stepper(totalSteps: 4));

    // Each step renders its 1-based number as text.
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  // 2. Current step is highlighted (its number text is present)
  testWidgets('current step circle is present', (tester) async {
    await tester.pumpObers(_stepper(currentStep: 1));

    // Step numbers 1, 2, 3 should all be rendered.
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  // 3. Completed steps show checkmark icon
  testWidgets('completed steps show checkmark icon', (tester) async {
    await tester.pumpObers(_stepper(currentStep: 2, completedSteps: {0, 1}));

    // Completed steps render an Icon widget with the check icon.
    final icons = tester.widgetList<Icon>(find.byType(Icon)).toList();
    // Two completed steps should each have a check icon.
    final checkIcons = icons
        .where((i) => i.icon?.codePoint == OiIcons.check.codePoint)
        .toList();
    expect(checkIcons.length, 2);
  });

  // 4. Error steps show error icon
  testWidgets('error steps show error icon', (tester) async {
    await tester.pumpObers(_stepper(currentStep: 1, errorSteps: {0}));

    final icons = tester.widgetList<Icon>(find.byType(Icon)).toList();
    // One error step should have the error icon.
    final errorIcons = icons
        .where((i) => i.icon?.codePoint == OiIcons.circleAlert.codePoint)
        .toList();
    expect(errorIcons.length, 1);
  });

  // 5. onStepTap fires with step index
  testWidgets('onStepTap fires with correct step index', (tester) async {
    int? tappedIndex;
    await tester.pumpObers(_stepper(onStepTap: (i) => tappedIndex = i));

    // Tap the second step circle (shows "2").
    await tester.tap(find.text('2'));
    await tester.pump();

    expect(tappedIndex, 1);
  });

  // 6. Horizontal layout renders a Row
  testWidgets('horizontal style renders a Row', (tester) async {
    await tester.pumpObers(_stepper(totalSteps: 2));

    // The horizontal layout uses a Row widget.
    expect(find.byType(Row), findsWidgets);
  });

  // 7. Vertical layout renders a Column
  testWidgets('vertical style renders a Column', (tester) async {
    await tester.pumpObers(
      _stepper(style: OiStepperStyle.vertical, totalSteps: 2),
    );

    // The vertical layout uses Column widgets.
    expect(find.byType(Column), findsWidgets);
  });

  // 8. Compact mode shows "Step N of M"
  testWidgets('compact style shows "Step N of M"', (tester) async {
    await tester.pumpObers(
      _stepper(style: OiStepperStyle.compact, totalSteps: 5, currentStep: 2),
    );

    expect(find.text('Step 3 of 5'), findsOneWidget);
  });

  // 9. Step labels render
  testWidgets('step labels render below step circles', (tester) async {
    await tester.pumpObers(
      _stepper(stepLabels: ['Account', 'Profile', 'Confirm']),
    );

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
  });

  // 10. Semantics label is present
  testWidgets('semantics label is provided', (tester) async {
    await tester.pumpObers(_stepper(totalSteps: 4, currentStep: 1));

    // The outermost Semantics widget has the label "Step 2 of 4".
    final semantics = tester.widgetList<Semantics>(find.byType(Semantics));
    final hasLabel = semantics.any((s) => s.properties.label == 'Step 2 of 4');
    expect(hasLabel, isTrue);
  });

  // 11. Vertical layout with labels renders labels beside circles
  testWidgets('vertical layout renders labels beside circles', (tester) async {
    await tester.pumpObers(
      _stepper(
        totalSteps: 2,
        style: OiStepperStyle.vertical,
        stepLabels: ['First', 'Second'],
      ),
    );

    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsOneWidget);
  });

  // 12. No onStepTap means tapping does nothing (no crash)
  testWidgets('tapping step without onStepTap does not crash', (tester) async {
    await tester.pumpObers(_stepper());

    // Should not throw.
    await tester.tap(find.text('2'));
    await tester.pump();
  });
}
