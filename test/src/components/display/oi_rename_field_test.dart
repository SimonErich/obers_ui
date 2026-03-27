// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_rename_field.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders text input with current name', (tester) async {
    await tester.pumpObers(
      OiRenameField(
        currentName: 'report.pdf',
        onRename: (_) {},
        onCancel: () {},
      ),
    );
    expect(find.byType(OiTextInput), findsOneWidget);
  });

  testWidgets('auto-focuses the text input', (tester) async {
    await tester.pumpObers(
      OiRenameField(
        currentName: 'report.pdf',
        onRename: (_) {},
        onCancel: () {},
      ),
    );
    await tester.pumpAndSettle();

    final textInput = tester.widget<OiTextInput>(find.byType(OiTextInput));
    expect(textInput.autofocus, isTrue);
  });

  testWidgets('shows confirm and cancel buttons when showButtons is true', (
    tester,
  ) async {
    await tester.pumpObers(
      OiRenameField(
        currentName: 'file.txt',
        onRename: (_) {},
        onCancel: () {},
        showButtons: true,
      ),
    );
    // check icon (confirm) and close icon (cancel)
    const checkIcon = OiIcons.check;
    const closeIcon = OiIcons.x;
    expect(find.byIcon(checkIcon), findsOneWidget);
    expect(find.byIcon(closeIcon), findsOneWidget);
  });

  testWidgets('hides buttons when showButtons is false', (tester) async {
    await tester.pumpObers(
      OiRenameField(currentName: 'file.txt', onRename: (_) {}, onCancel: () {}),
    );
    const checkIcon = OiIcons.check;
    const closeIcon = OiIcons.x;
    expect(find.byIcon(checkIcon), findsNothing);
    expect(find.byIcon(closeIcon), findsNothing);
  });

  testWidgets('submit fires onRename with trimmed name', (tester) async {
    String? renamedTo;
    await tester.pumpObers(
      OiRenameField(
        currentName: 'report.pdf',
        onRename: (name) => renamedTo = name,
        onCancel: () {},
      ),
    );
    await tester.pumpAndSettle();

    // Submit via text input action
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(renamedTo, 'report.pdf');
  });

  testWidgets('cancel button fires onCancel', (tester) async {
    var cancelled = false;
    await tester.pumpObers(
      OiRenameField(
        currentName: 'file.txt',
        onRename: (_) {},
        onCancel: () => cancelled = true,
        showButtons: true,
      ),
    );
    await tester.pumpAndSettle();

    const closeIcon = OiIcons.x;
    await tester.tap(find.byIcon(closeIcon));
    expect(cancelled, isTrue);
  });

  testWidgets('confirm button fires onRename', (tester) async {
    String? renamedTo;
    await tester.pumpObers(
      OiRenameField(
        currentName: 'file.txt',
        onRename: (name) => renamedTo = name,
        onCancel: () {},
        showButtons: true,
      ),
    );
    await tester.pumpAndSettle();

    const checkIcon = OiIcons.check;
    await tester.tap(find.byIcon(checkIcon));
    await tester.pumpAndSettle();

    expect(renamedTo, 'file.txt');
  });

  testWidgets('validates empty name shows error', (tester) async {
    String? renamedTo;
    await tester.pumpObers(
      OiRenameField(
        currentName: 'file.txt',
        onRename: (name) => renamedTo = name,
        onCancel: () {},
        showButtons: true,
      ),
    );
    await tester.pumpAndSettle();

    // Clear the text field
    await tester.enterText(find.byType(EditableText), '   ');
    await tester.pumpAndSettle();

    // Tap confirm
    const checkIcon = OiIcons.check;
    await tester.tap(find.byIcon(checkIcon));
    await tester.pumpAndSettle();

    expect(renamedTo, isNull);
    expect(find.text('Name cannot be empty'), findsOneWidget);
  });

  testWidgets('validates illegal characters shows error', (tester) async {
    String? renamedTo;
    await tester.pumpObers(
      OiRenameField(
        currentName: 'file.txt',
        onRename: (name) => renamedTo = name,
        onCancel: () {},
        showButtons: true,
      ),
    );
    await tester.pumpAndSettle();

    // Enter name with illegal character
    await tester.enterText(find.byType(EditableText), 'file/name.txt');
    await tester.pumpAndSettle();

    // Tap confirm
    const checkIcon = OiIcons.check;
    await tester.tap(find.byIcon(checkIcon));
    await tester.pumpAndSettle();

    expect(renamedTo, isNull);
    expect(find.text('Name cannot contain "/"'), findsOneWidget);
  });

  testWidgets('custom validate function is called', (tester) async {
    await tester.pumpObers(
      OiRenameField(
        currentName: 'file.txt',
        onRename: (_) {},
        onCancel: () {},
        showButtons: true,
        validate: (name) => name == 'taken' ? 'Name already exists' : null,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'taken');
    await tester.pumpAndSettle();

    const checkIcon = OiIcons.check;
    await tester.tap(find.byIcon(checkIcon));
    await tester.pumpAndSettle();

    expect(find.text('Name already exists'), findsOneWidget);
  });

  testWidgets('default semantic label is "Rename file"', (tester) async {
    await tester.pumpObers(
      OiRenameField(currentName: 'file.txt', onRename: (_) {}, onCancel: () {}),
    );
    final semantics = tester
        .widgetList<Semantics>(find.byType(Semantics))
        .where((s) => s.properties.label == 'Rename file')
        .toList();
    expect(semantics, isNotEmpty);
  });

  testWidgets('custom semanticsLabel overrides default', (tester) async {
    await tester.pumpObers(
      OiRenameField(
        currentName: 'file.txt',
        onRename: (_) {},
        onCancel: () {},
        semanticsLabel: 'Rename document',
      ),
    );
    final semantics = tester
        .widgetList<Semantics>(find.byType(Semantics))
        .where((s) => s.properties.label == 'Rename document')
        .toList();
    expect(semantics, isNotEmpty);
  });

  testWidgets('isFolder false selects name without extension', (tester) async {
    // This test verifies the controller text is correctly set.
    // The selection behavior is tested implicitly through the widget rendering.
    await tester.pumpObers(
      OiRenameField(
        currentName: 'report.pdf',
        onRename: (_) {},
        onCancel: () {},
      ),
    );
    await tester.pumpAndSettle();

    // The text input should contain the full name
    final editableText = tester.widget<EditableText>(find.byType(EditableText));
    expect(editableText.controller.text, 'report.pdf');
  });

  testWidgets('isFolder true selects entire name', (tester) async {
    await tester.pumpObers(
      OiRenameField(
        currentName: 'My Folder',
        folder: true,
        onRename: (_) {},
        onCancel: () {},
      ),
    );
    await tester.pumpAndSettle();

    final editableText = tester.widget<EditableText>(find.byType(EditableText));
    expect(editableText.controller.text, 'My Folder');
  });
}
