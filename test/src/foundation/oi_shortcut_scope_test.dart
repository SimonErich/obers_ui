import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/oi_shortcut_scope.dart';
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

  group('redo', () {
    Future<void> press(
      WidgetTester tester,
      List<LogicalKeyboardKey> modifiers,
      LogicalKeyboardKey key,
    ) async {
      for (final modifier in modifiers) {
        await tester.sendKeyDownEvent(modifier);
      }
      await tester.sendKeyEvent(key);
      for (final modifier in modifiers.reversed) {
        await tester.sendKeyUpEvent(modifier);
      }
      await tester.pump();
    }

    Future<OiUndoStack> pumpWithUndoneAction(
      WidgetTester tester,
      VoidCallback onRedo,
    ) async {
      late OiUndoStack stack;
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
      stack
        ..push(OiUndoAction(label: 'Rename', execute: onRedo, undo: () {}))
        ..undo();
      return stack;
    }

    for (final (name, modifiers, key) in [
      (
        'Ctrl+Shift+Z',
        [LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.shiftLeft],
        LogicalKeyboardKey.keyZ,
      ),
      (
        'Cmd+Shift+Z',
        [LogicalKeyboardKey.metaLeft, LogicalKeyboardKey.shiftLeft],
        LogicalKeyboardKey.keyZ,
      ),
      ('Ctrl+Y', [LogicalKeyboardKey.controlLeft], LogicalKeyboardKey.keyY),
    ]) {
      testWidgets('$name redoes the undo stack', (tester) async {
        var redone = 0;
        final stack = await pumpWithUndoneAction(tester, () => redone++);
        expect(stack.canRedo, isTrue);

        await press(tester, modifiers, key);

        expect(redone, 1);
        expect(stack.canRedo, isFalse);
        expect(stack.canUndo, isTrue);
      });
    }

    testWidgets('Ctrl+Shift+Z does not also undo', (tester) async {
      var undone = 0;
      late OiUndoStack stack;
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

      await press(tester, [
        LogicalKeyboardKey.controlLeft,
        LogicalKeyboardKey.shiftLeft,
      ], LogicalKeyboardKey.keyZ);

      expect(undone, 0);
    });

    testWidgets('in a text field the stack is left alone', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      late OiUndoStack stack;
      var redone = 0;
      await tester.pumpWidget(
        OiApp(
          home: Builder(
            builder: (context) {
              stack = OiUndoStack.of(context);
              return OiRawInput(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
              );
            },
          ),
        ),
      );
      await tester.pump();
      stack
        ..push(OiUndoAction(label: 'x', execute: () => redone++, undo: () {}))
        ..undo();

      await press(tester, [
        LogicalKeyboardKey.controlLeft,
        LogicalKeyboardKey.shiftLeft,
      ], LogicalKeyboardKey.keyZ);

      expect(redone, 0);
    });
  });

  group('? help', () {
    Future<void> typeQuestionMark(WidgetTester tester) async {
      // A real "?" is Shift+/ on most layouts: Shift is held while the key
      // that produces the character is pressed.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.slash, character: '?');
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
    }

    testWidgets('a typed "?" requests help', (tester) async {
      late OiShortcutScopeState state;
      await tester.pumpWidget(
        OiApp(
          home: Builder(
            builder: (context) {
              state = OiShortcutScope.of(context);
              return const Focus(autofocus: true, child: SizedBox());
            },
          ),
        ),
      );
      await tester.pump();
      expect(state.helpActive.value, isFalse);

      await typeQuestionMark(tester);

      expect(state.helpActive.value, isTrue);
    });

    testWidgets('a "?" typed into a text field is left to the field', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      late OiShortcutScopeState state;
      await tester.pumpWidget(
        OiApp(
          home: Builder(
            builder: (context) {
              state = OiShortcutScope.of(context);
              return OiRawInput(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
              );
            },
          ),
        ),
      );
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      final handled = await tester.sendKeyDownEvent(
        LogicalKeyboardKey.slash,
        character: '?',
      );
      await tester.sendKeyUpEvent(LogicalKeyboardKey.slash);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();

      expect(state.helpActive.value, isFalse);
      expect(handled, isFalse, reason: 'the key must reach the text input');
    });
  });
}
