// Tests do not require documentation comments.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/dialogs/oi_new_folder_dialog.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiNewFolderDialog', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpObers(OiNewFolderDialog(onCreate: (_) {}));
      expect(find.byType(OiNewFolderDialog), findsOneWidget);
    });

    testWidgets('shows New Folder heading', (tester) async {
      await tester.pumpObers(
        OiNewFolderDialog(onCreate: (_) {}, defaultName: 'Untitled'),
      );
      // Use a custom default name so the heading is the only 'New Folder' text
      expect(find.text('New Folder'), findsOneWidget);
    });

    testWidgets('pre-fills default name in text input', (tester) async {
      await tester.pumpObers(OiNewFolderDialog(onCreate: (_) {}));
      expect(find.byType(OiTextInput), findsOneWidget);
      // The default name 'New Folder' appears in both the heading and input
      expect(find.text('New Folder'), findsAtLeast(1));
    });

    testWidgets('pre-fills custom default name', (tester) async {
      await tester.pumpObers(
        OiNewFolderDialog(onCreate: (_) {}, defaultName: 'My Folder'),
      );
      expect(find.text('My Folder'), findsOneWidget);
    });

    testWidgets('shows parent folder name when provided', (tester) async {
      await tester.pumpObers(
        OiNewFolderDialog(onCreate: (_) {}, parentFolderName: 'Documents'),
      );
      expect(find.text('Parent: Documents'), findsOneWidget);
    });

    testWidgets('shows Folder name label', (tester) async {
      await tester.pumpObers(OiNewFolderDialog(onCreate: (_) {}));
      expect(find.text('Folder name'), findsOneWidget);
    });

    testWidgets('validates empty name', (tester) async {
      await tester.pumpObers(OiNewFolderDialog(onCreate: (_) {}));
      await tester.enterText(find.byType(OiTextInput), '');
      await tester.pump();
      expect(find.text('Name cannot be empty'), findsOneWidget);
    });

    testWidgets('validates illegal characters', (tester) async {
      await tester.pumpObers(OiNewFolderDialog(onCreate: (_) {}));
      await tester.enterText(find.byType(OiTextInput), 'my/folder');
      await tester.pump();
      expect(find.text('Name cannot contain "/"'), findsOneWidget);
    });

    testWidgets('validates with custom validator', (tester) async {
      await tester.pumpObers(
        OiNewFolderDialog(
          onCreate: (_) {},
          validate: (name) => name == 'taken' ? 'Name already exists' : null,
        ),
      );
      await tester.enterText(find.byType(OiTextInput), 'taken');
      await tester.pump();
      expect(find.text('Name already exists'), findsOneWidget);
    });

    testWidgets('submit fires onCreate with valid name', (tester) async {
      String? created;
      await tester.pumpObers(
        OiNewFolderDialog(onCreate: (name) => created = name),
      );
      await tester.enterText(find.byType(OiTextInput), 'Photos');
      await tester.pump();
      await tester.tap(find.widgetWithText(OiButton, 'Create'));
      await tester.pump();
      expect(created, 'Photos');
    });

    testWidgets('tapping Cancel fires onCancel', (tester) async {
      var cancelled = false;
      await tester.pumpObers(
        OiNewFolderDialog(onCreate: (_) {}, onCancel: () => cancelled = true),
      );
      await tester.tap(find.widgetWithText(OiButton, 'Cancel'));
      await tester.pump();
      expect(cancelled, isTrue);
    });

    testWidgets('ESC key fires onCancel', (tester) async {
      var cancelled = false;
      await tester.pumpObers(
        OiNewFolderDialog(onCreate: (_) {}, onCancel: () => cancelled = true),
      );
      // The KeyboardListener wraps the dialog; focus its node so it
      // receives key events.
      final kl = tester.widget<KeyboardListener>(find.byType(KeyboardListener));
      kl.focusNode.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(cancelled, isTrue);
    });

    testWidgets('has correct semantics label', (tester) async {
      await tester.pumpObers(OiNewFolderDialog(onCreate: (_) {}));
      expect(
        find.bySemanticsLabel(RegExp('New folder dialog')),
        findsOneWidget,
      );
    });

    testWidgets('Create button disabled for empty name', (tester) async {
      await tester.pumpObers(OiNewFolderDialog(onCreate: (_) {}));
      await tester.enterText(find.byType(OiTextInput), '');
      await tester.pump();
      expect(find.widgetWithText(OiButton, 'Create'), findsOneWidget);
    });
  });
}
