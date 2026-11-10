// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/forms/oi_stepper.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_component_themes.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';

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
  testWidgets('timeline rail tracks intrinsic details with themed indicators', (
    tester,
  ) async {
    const appearance = OiStepperThemeData(
      indicatorBorderColor: Color(0xff90919a),
      indicatorBorderWidth: 1,
      connectorColor: Color(0xffc7c8d0),
      stepSpacing: 20,
      detailsSpacing: 2,
    );
    final base = OiThemeData.light();
    await tester.pumpObers(
      const Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 312,
          child: OiStepper(
            totalSteps: 3,
            currentStep: -1,
            style: OiStepperStyle.vertical,
            timeline: true,
            indicatorSize: 24,
            labelStyle: TextStyle(fontSize: 14, height: 24 / 14),
            stepLabels: ['First\nSecond', 'Kitchen', 'Delivery'],
            stepDetails: [
              SizedBox(height: 76, child: Text('Person context')),
              SizedBox(height: 16, child: Text('After approval')),
              SizedBox(height: 16, child: Text('At reception')),
            ],
          ),
        ),
      ),
      theme: base.copyWith(
        components: base.components.copyWith(stepper: appearance),
      ),
    );
    final first = tester.getTopLeft(find.text('First\nSecond'));
    final second = tester.getTopLeft(find.text('Kitchen'));
    final third = tester.getTopLeft(find.text('Delivery'));
    expect(second.dy - first.dy, closeTo(146, .01));
    expect(third.dy - second.dy, closeTo(62, .01));
    expect(tester.getTopLeft(find.text('Person context')).dy - first.dy, 50);
    final circles = tester.widgetList<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    expect(circles.length, 3);
    for (final circle in circles) {
      final decoration = circle.decoration! as BoxDecoration;
      expect(
        decoration.border,
        Border.all(color: appearance.indicatorBorderColor!),
      );
    }
    final rails = find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration! as BoxDecoration).color ==
              appearance.connectorColor,
    );
    expect(rails, findsNWidgets(2));
    expect(tester.getSize(rails.first), const Size(2, 114));
    expect(tester.getTopLeft(rails.first).dy - first.dy, 28);
    expect(tester.takeException(), isNull);
    expect(appearance.copyWith(), appearance);
    expect(appearance.copyWith().hashCode, appearance.hashCode);
    expect(base.components.copyWith(stepper: appearance).stepper, appearance);
    expect(
      base.components.copyWith(stepper: appearance),
      base.components.copyWith(stepper: appearance.copyWith()),
    );
  });

  testWidgets('omitted timeline preserves ordinary and compact layouts', (
    tester,
  ) async {
    await tester.pumpObers(_stepper(style: OiStepperStyle.vertical));
    final circle = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer).first,
    );
    expect((circle.decoration! as BoxDecoration).border!.top.width, 2);
    await tester.pumpObers(
      const OiStepper(
        totalSteps: 3,
        currentStep: 1,
        timeline: true,
        style: OiStepperStyle.compact,
      ),
    );
    expect(find.text('Step 2 of 3'), findsOneWidget);
    expect(find.byType(AnimatedContainer), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpObers(
      const OiStepper(
        totalSteps: 3,
        currentStep: -1,
        timeline: true,
        style: OiStepperStyle.vertical,
        stepLabels: ['One', 'Two', 'Three'],
        stepDetails: [],
      ),
    );
    expect(find.text('Three'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('upcoming appearance preserves active and error state strokes', (
    tester,
  ) async {
    final base = OiThemeData.light();
    await tester.pumpObers(
      const OiStepper(
        totalSteps: 4,
        currentStep: 1,
        completedSteps: {0},
        errorSteps: {2},
      ),
      theme: base.copyWith(
        components: base.components.copyWith(
          stepper: const OiStepperThemeData(
            indicatorBorderWidth: 1,
            indicatorBorderColor: Color(0xff90919a),
          ),
        ),
      ),
    );
    final decorations = tester
        .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
        .map((circle) => circle.decoration! as BoxDecoration)
        .toList();
    expect(decorations.map((d) => d.border!.top.width), [2, 2, 2, 1]);
    expect(decorations[0].border!.top.color, base.colors.success.base);
    expect(decorations[1].border!.top.color, base.colors.primary.base);
    expect(decorations[2].border!.top.color, base.colors.error.base);
    expect(decorations[3].border!.top.color, const Color(0xff90919a));
    expect(tester.takeException(), isNull);
  });

  testWidgets('vertical detailed indicators align with the first line', (
    tester,
  ) async {
    await tester.pumpObers(
      const Center(
        child: SizedBox(
          width: 300,
          child: OiStepper(
            totalSteps: 2,
            currentStep: -1,
            style: OiStepperStyle.vertical,
            stepLabels: ['Approve', 'Deliver'],
            indicatorSize: 24,
            stepDetails: [
              SizedBox(height: 100, child: Text('Approver context')),
              Text('Later'),
            ],
          ),
        ),
      ),
    );
    final indicator = tester.getCenter(find.text('1'));
    final title = tester.getTopLeft(find.text('Approve'));
    expect(indicator.dy, closeTo(title.dy + 12, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('detailed steps align indicators and wrap at narrow widths', (
    tester,
  ) async {
    await tester.pumpObers(
      const SizedBox(
        width: 420,
        child: OiStepper(
          totalSteps: 3,
          currentStep: 1,
          stepLabels: ['Placed', 'In kitchen', 'Delivered'],
          stepDetails: [
            Text('08:04 by Lena'),
            Text('08:12 by the kitchen team'),
            Text('Expected at reception'),
          ],
          completedSteps: {0},
          completedColor: Color(0xff665eae),
          currentOutlined: true,
          indicatorSize: 24,
        ),
      ),
    );
    expect(find.text('08:12 by the kitchen team'), findsOneWidget);
    expect(find.text('Expected at reception'), findsOneWidget);
    expect(tester.takeException(), isNull);
    final stepper = tester.widget<OiStepper>(find.byType(OiStepper));
    expect(stepper.completedSteps, {0});
    expect(stepper.currentStep, 1);
  });
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
