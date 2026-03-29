// Tests do not require documentation comments.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/dialogs/oi_name_dialog.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiNameDialog', () {
    // ── REQ-0910 ──────────────────────────────────────────────────────────

    testWidgets('pre-fills defaultName and selects all text on open', (
      tester,
    ) async {
      await tester.pumpObers(
        OiNameDialog(
          title: 'New folder',
          defaultName: 'Untitled',
          onCreate: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      final editableText = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(editableText.controller.text, 'Untitled');
      expect(
        editableText.controller.selection,
        const TextSelection(baseOffset: 0, extentOffset: 8),
      );
    });

    testWidgets('auto-focuses the input on open', (tester) async {
      await tester.pumpObers(
        OiNameDialog(title: 'New item', defaultName: 'Item', onCreate: (_) {}),
      );
      await tester.pumpAndSettle();

      // After open, focus should be inside the dialog. The focus manager's
      // primary focus should be within the EditableText's focus tree.
      final primaryFocus = FocusManager.instance.primaryFocus;
      expect(primaryFocus, isNotNull);

      // The primary focus should be a descendant of the dialog content area.
      // We verify by confirming the focus scope enclosing the primary focus
      // belongs to the OiFocusTrap (i.e. it is inside the dialog).
      final editableFinder = find.byType(EditableText);
      expect(editableFinder, findsOneWidget);
      final editableContext = tester.element(editableFinder);
      final enclosingScope = FocusScope.of(editableContext);
      expect(enclosingScope.hasFocus, isTrue);
    });

    // ── REQ-0911 ──────────────────────────────────────────────────────────

    testWidgets('Enter key triggers onCreate with current value', (
      tester,
    ) async {
      String? createdName;
      await tester.pumpObers(
        OiNameDialog(
          title: 'Create',
          defaultName: 'MyFile',
          onCreate: (name) => createdName = name,
        ),
      );
      await tester.pumpAndSettle();

      // Show keyboard to connect the test text input, then submit.
      await tester.showKeyboard(find.byType(EditableText));
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(createdName, 'MyFile');
    });

    testWidgets('Enter key does not fire onCreate when input is empty', (
      tester,
    ) async {
      String? createdName;
      await tester.pumpObers(
        OiNameDialog(title: 'Create', onCreate: (name) => createdName = name),
      );
      await tester.pumpAndSettle();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(createdName, isNull);
    });

    testWidgets('Enter key does not fire onCreate when validation fails', (
      tester,
    ) async {
      String? createdName;
      await tester.pumpObers(
        OiNameDialog(
          title: 'Create',
          defaultName: 'bad',
          onCreate: (name) => createdName = name,
          validate: (v) => v == 'bad' ? 'Name is reserved' : null,
        ),
      );
      await tester.pumpAndSettle();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(createdName, isNull);
    });

    // ── REQ-0912 ──────────────────────────────────────────────────────────

    testWidgets('Escape key triggers onCancel', (tester) async {
      var cancelled = false;
      await tester.pumpObers(
        OiNameDialog(
          title: 'Create',
          defaultName: 'Test',
          onCreate: (_) {},
          onCancel: () => cancelled = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      expect(cancelled, isTrue);
    });

    testWidgets('renders title', (tester) async {
      await tester.pumpObers(
        OiNameDialog(
          title: 'Rename file',
          defaultName: 'doc.txt',
          onCreate: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rename file'), findsOneWidget);
    });

    testWidgets('renders Cancel and Create buttons', (tester) async {
      await tester.pumpObers(
        OiNameDialog(
          title: 'New',
          defaultName: 'Item',
          onCreate: (_) {},
          onCancel: () {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('custom button labels', (tester) async {
      await tester.pumpObers(
        OiNameDialog(
          title: 'Rename file',
          defaultName: 'Old',
          createLabel: 'Save',
          cancelLabel: 'Discard',
          onCreate: (_) {},
          onCancel: () {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Discard'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('validation error is displayed', (tester) async {
      await tester.pumpObers(
        OiNameDialog(
          title: 'Create',
          defaultName: 'good',
          onCreate: (_) {},
          validate: (v) => v == 'bad' ? 'Name is reserved' : null,
        ),
      );
      await tester.pumpAndSettle();

      // Type an invalid name.
      await tester.enterText(find.byType(EditableText), 'bad');
      await tester.pumpAndSettle();

      expect(find.text('Name is reserved'), findsOneWidget);
    });

    // ── REQ-0914 ──────────────────────────────────────────────────────────

    testWidgets('Create button does not fire onCreate when input is empty', (
      tester,
    ) async {
      String? createdName;
      await tester.pumpObers(
        OiNameDialog(title: 'New item', onCreate: (name) => createdName = name),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(createdName, isNull);
    });

    testWidgets('Create button does not fire onCreate when validation fails', (
      tester,
    ) async {
      String? createdName;
      await tester.pumpObers(
        OiNameDialog(
          title: 'New item',
          defaultName: 'bad',
          onCreate: (name) => createdName = name,
          validate: (v) => v == 'bad' ? 'Name is reserved' : null,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(createdName, isNull);
    });

    testWidgets('Create button re-enables after fixing validation error', (
      tester,
    ) async {
      String? createdName;
      await tester.pumpObers(
        OiNameDialog(
          title: 'New item',
          defaultName: 'bad',
          onCreate: (name) => createdName = name,
          validate: (v) => v == 'bad' ? 'Name is reserved' : null,
        ),
      );
      await tester.pumpAndSettle();

      // Fix the invalid name.
      await tester.enterText(find.byType(EditableText), 'good');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(createdName, 'good');
    });

    // ── REQ-0913 ──────────────────────────────────────────────────────────

    testWidgets('rejects name containing illegal characters', (tester) async {
      await tester.pumpObers(
        OiNameDialog(title: 'Create', defaultName: 'good', onCreate: (_) {}),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EditableText), 'my/file');
      await tester.pumpAndSettle();

      expect(
        find.text(r'Name cannot contain: / \ < > : " | ? *'),
        findsOneWidget,
      );
    });

    testWidgets(
      'Create button is disabled when name contains illegal characters',
      (tester) async {
        String? createdName;
        await tester.pumpObers(
          OiNameDialog(
            title: 'New item',
            defaultName: 'good',
            onCreate: (name) => createdName = name,
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(EditableText), 'file<name>');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Create'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(createdName, isNull);
      },
    );

    testWidgets(
      'Enter key does not fire onCreate when name contains illegal characters',
      (tester) async {
        String? createdName;
        await tester.pumpObers(
          OiNameDialog(
            title: 'Create',
            defaultName: 'good',
            onCreate: (name) => createdName = name,
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(EditableText), 'file:name');
        await tester.pumpAndSettle();

        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(createdName, isNull);
      },
    );

    testWidgets('Create button re-enables after removing illegal characters', (
      tester,
    ) async {
      String? createdName;
      await tester.pumpObers(
        OiNameDialog(
          title: 'New item',
          defaultName: 'good',
          onCreate: (name) => createdName = name,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EditableText), 'my|file');
      await tester.pumpAndSettle();

      // Fix the name.
      await tester.enterText(find.byType(EditableText), 'myfile');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(createdName, 'myfile');
    });

    testWidgets('built-in check runs before custom validate', (tester) async {
      await tester.pumpObers(
        OiNameDialog(
          title: 'Create',
          defaultName: 'good',
          onCreate: (_) {},
          validate: (_) => 'Custom error',
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EditableText), 'bad/name');
      await tester.pumpAndSettle();

      // Built-in error should be shown, not the custom one.
      expect(
        find.text(r'Name cannot contain: / \ < > : " | ? *'),
        findsOneWidget,
      );
      expect(find.text('Custom error'), findsNothing);
    });

    for (final ch in ['/', r'\', '<', '>', ':', '"', '|', '?', '*']) {
      testWidgets('rejects illegal character: $ch', (tester) async {
        await tester.pumpObers(
          OiNameDialog(title: 'Create', defaultName: 'good', onCreate: (_) {}),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(EditableText), 'name${ch}here');
        await tester.pumpAndSettle();

        expect(
          find.text(r'Name cannot contain: / \ < > : " | ? *'),
          findsOneWidget,
        );
      });
    }

    // ── General behaviour ─────────────────────────────────────────────────

    testWidgets('Cancel button calls onCancel', (tester) async {
      var cancelled = false;
      await tester.pumpObers(
        OiNameDialog(
          title: 'Create',
          defaultName: 'Test',
          onCreate: (_) {},
          onCancel: () => cancelled = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(cancelled, isTrue);
    });
  });
}
