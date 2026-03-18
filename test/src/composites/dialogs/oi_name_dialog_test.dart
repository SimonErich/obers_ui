// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

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
        OiNameDialog(
          title: 'New item',
          defaultName: 'Item',
          onCreate: (_) {},
        ),
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

      // Tap the input to connect the test text input, then submit.
      await tester.tap(find.byType(EditableText));
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
        OiNameDialog(
          title: 'Create',
          onCreate: (name) => createdName = name,
        ),
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

    // ── General behaviour ─────────────────────────────────────────────────

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
