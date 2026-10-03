import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('disclosure keyboard toggle preserves hidden editor state', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var expanded = false;
    await tester.pumpObers(
      StatefulBuilder(
        builder: (context, setState) => SizedBox(
          width: 280,
          child: OiDisclosure(
            title: 'Another address',
            description: 'For this delivery only',
            expanded: expanded,
            onChanged: (value) => setState(() => expanded = value),
            child: const OiTextInput(label: 'Street'),
          ),
        ),
      ),
    );
    expect(find.byType(EditableText), findsNothing);
    expect(find.bySemanticsLabel('Expand Another address'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(expanded, isTrue);
    await tester.enterText(find.byType(EditableText), 'Main street');
    await tester.tap(find.text('Another address'));
    await tester.pumpAndSettle();
    expect(find.byType(EditableText), findsNothing);
    await tester.tap(find.text('Another address'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      'Main street',
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}
