import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/oi_undo_stack.dart';
import 'package:obers_ui/src/primitives/input/oi_raw_input.dart';

void main() {
  // A text field records an edit for undo a moment after typing stops.
  const settle = Duration(milliseconds: 600);

  Future<void> pressUndo(WidgetTester tester) async {
    final apple = defaultTargetPlatform == TargetPlatform.macOS;
    final modifier = apple
        ? LogicalKeyboardKey.metaLeft
        : LogicalKeyboardKey.controlLeft;
    await tester.sendKeyDownEvent(modifier);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
    await tester.sendKeyUpEvent(modifier);
    await tester.pump();
  }

  OiUndoAction counted(void Function() onUndo) =>
      OiUndoAction(label: 'Rename', execute: () {}, undo: onUndo);

  group('Ctrl+Z', () {
    testWidgets('in a text field undoes its typing, not the undo stack', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      late OiUndoStack stack;
      var undone = 0;
      await tester.pumpWidget(
        OiApp(
          home: Builder(
            builder: (context) {
              stack = OiUndoStack.of(context);
              return OiRawInput(controller: controller, focusNode: focusNode);
            },
          ),
        ),
      );
      stack.push(counted(() => undone++));

      await tester.enterText(find.byType(EditableText), 'Bounded contexts');
      await tester.pump(settle);
      await tester.enterText(find.byType(EditableText), '');
      await tester.pump(settle);
      await pressUndo(tester);

      expect(controller.text, 'Bounded contexts');
      expect(undone, 0);
    });

    testWidgets('elsewhere undoes the undo stack', (tester) async {
      late OiUndoStack stack;
      var undone = 0;
      await tester.pumpWidget(
        OiApp(
          home: Builder(
            builder: (context) {
              stack = OiUndoStack.of(context);
              return const Focus(autofocus: true, child: SizedBox());
            },
          ),
        ),
      );
      await tester.pump();
      stack.push(counted(() => undone++));

      await pressUndo(tester);

      expect(undone, 1);
    });
  });
}
