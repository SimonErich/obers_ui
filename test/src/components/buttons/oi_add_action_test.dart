import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_add_action.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('search insertion keeps button semantics and keyboard behavior', (
    tester,
  ) async {
    var activated = 0;
    final semantics = tester.ensureSemantics();
    await tester.pumpObers(
      Center(
        child: SizedBox(
          width: 320,
          child: OiAddAction(
            label: 'Add a dish',
            placeholder: 'Add a dish, e.g. Falafel wrap',
            presentation: OiAddActionPresentation.search,
            onTap: () => activated++,
          ),
        ),
      ),
    );
    expect(find.byType(EditableText), findsNothing);
    expect(tester.getSize(find.byType(OiAddAction)).height, 36);
    expect(find.bySemanticsLabel('Add a dish'), findsOneWidget);
    final hint = find.text('Add a dish, e.g. Falafel wrap');
    await tester.tap(hint);
    expect(activated, 1);
    Focus.of(tester.element(hint)).requestFocus();
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(activated, 2);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}
