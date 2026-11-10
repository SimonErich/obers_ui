import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  for (final width in [390.0, 1440.0]) {
    testWidgets(
      'step heading and actions stay visible while scrolling at $width',
      (
        tester,
      ) async {
        await tester.pumpObers(
          OiWizardLayout(
            steps: const [OiWizardStepPresentation(title: 'Basics')],
            currentStep: 0,
            stepHeader: const Text('Persistent heading'),
            footer: const Text('Continue action'),
            scrollable: true,
            child: const Column(
              children: [
                Text('First input'),
                SizedBox(height: 1400),
                OiTextInput(label: 'Last input'),
              ],
            ),
          ),
          surfaceSize: Size(width, 1000),
        );
        final header = tester.getRect(find.text('Persistent heading'));
        final footer = tester.getRect(find.text('Continue action'));
        final scroll = find.ancestor(
          of: find.text('First input'),
          matching: find.byType(SingleChildScrollView),
        );
        await tester.drag(scroll, const Offset(0, -1000));
        await tester.pumpAndSettle();
        expect(tester.getRect(find.text('Persistent heading')), header);
        expect(tester.getRect(find.text('Continue action')), footer);
        await tester.ensureVisible(find.byType(EditableText));
        await tester.pumpAndSettle();
        expect(tester.getRect(find.text('Persistent heading')), header);
        expect(find.byType(EditableText).hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'short frames scroll the header so lower inputs remain reachable',
    (
      tester,
    ) async {
      await tester.pumpObers(
        OiWizardLayout(
          steps: const [OiWizardStepPresentation(title: 'Basics')],
          currentStep: 0,
          stepHeader: const Text('Heading in short frame'),
          footer: const Text('Pinned action'),
          scrollable: true,
          child: const Column(
            children: [SizedBox(height: 600), Text('Last row')],
          ),
        ),
        surfaceSize: const Size(390, 400),
      );
      final footer = tester.getRect(find.text('Pinned action'));
      await tester.ensureVisible(find.text('Last row'));
      await tester.pumpAndSettle();
      expect(find.text('Last row').hitTestable(), findsOneWidget);
      expect(find.text('Heading in short frame').hitTestable(), findsNothing);
      expect(tester.getRect(find.text('Pinned action')), footer);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('changing steps resets only the step body scroll position', (
    tester,
  ) async {
    late StateSetter update;
    var step = 0;
    await tester.pumpObers(
      StatefulBuilder(
        builder: (context, setState) {
          update = setState;
          return OiWizardLayout(
            steps: const [
              OiWizardStepPresentation(title: 'First'),
              OiWizardStepPresentation(title: 'Second'),
            ],
            currentStep: step,
            stepHeader: Text('Heading $step'),
            scrollable: true,
            child: Column(
              children: [Text('Start $step'), const SizedBox(height: 1600)],
            ),
          );
        },
      ),
      surfaceSize: const Size(1440, 1000),
    );
    final start = tester.getTopLeft(find.text('Start 0'));
    final scroll = find.ancestor(
      of: find.text('Start 0'),
      matching: find.byType(SingleChildScrollView),
    );
    await tester.drag(scroll, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Start 0')).dy, lessThan(start.dy));
    update(() => step = 1);
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('Start 1')), start);
    expect(tester.takeException(), isNull);
  });
}
