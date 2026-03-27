// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/dialogs/oi_rename_dialog.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiRenameDialog', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpObers(
        OiRenameDialog(
          file: const OiFileNodeData(
            id: '1',
            name: 'report.pdf',
            folder: false,
          ),
          onRename: (_) {},
        ),
      );
      expect(find.byType(OiRenameDialog), findsOneWidget);
    });

    testWidgets('shows Rename title', (tester) async {
      await tester.pumpObers(
        OiRenameDialog(
          file: const OiFileNodeData(
            id: '1',
            name: 'report.pdf',
            folder: false,
          ),
          onRename: (_) {},
        ),
      );
      expect(find.text('Rename'), findsAtLeast(1));
    });

    testWidgets('pre-fills current file name', (tester) async {
      await tester.pumpObers(
        OiRenameDialog(
          file: const OiFileNodeData(
            id: '1',
            name: 'report.pdf',
            folder: false,
          ),
          onRename: (_) {},
        ),
      );
      expect(find.text('report.pdf'), findsOneWidget);
    });

    testWidgets('validates empty name', (tester) async {
      await tester.pumpObers(
        OiRenameDialog(
          file: const OiFileNodeData(
            id: '1',
            name: 'report.pdf',
            folder: false,
          ),
          onRename: (_) {},
        ),
      );
      await tester.enterText(find.byType(OiTextInput), '');
      await tester.pump();
      expect(find.text('Name cannot be empty'), findsOneWidget);
    });

    testWidgets('validates illegal characters', (tester) async {
      await tester.pumpObers(
        OiRenameDialog(
          file: const OiFileNodeData(
            id: '1',
            name: 'report.pdf',
            folder: false,
          ),
          onRename: (_) {},
        ),
      );
      await tester.enterText(find.byType(OiTextInput), 'my:file.pdf');
      await tester.pump();
      expect(find.text('Name cannot contain ":"'), findsOneWidget);
    });

    testWidgets('validates with custom validator', (tester) async {
      await tester.pumpObers(
        OiRenameDialog(
          file: const OiFileNodeData(
            id: '1',
            name: 'report.pdf',
            folder: false,
          ),
          onRename: (_) {},
          validate: (name) =>
              name == 'existing.pdf' ? 'Name already taken' : null,
        ),
      );
      await tester.enterText(find.byType(OiTextInput), 'existing.pdf');
      await tester.pump();
      expect(find.text('Name already taken'), findsOneWidget);
    });

    testWidgets('submit fires onRename with new name', (tester) async {
      String? renamed;
      await tester.pumpObers(
        OiRenameDialog(
          file: const OiFileNodeData(
            id: '1',
            name: 'report.pdf',
            folder: false,
          ),
          onRename: (name) => renamed = name,
        ),
      );
      await tester.enterText(find.byType(OiTextInput), 'summary.pdf');
      await tester.pump();
      await tester.tap(find.widgetWithText(OiButton, 'Rename'));
      await tester.pump();
      expect(renamed, 'summary.pdf');
    });

    testWidgets('Rename button disabled when name unchanged', (tester) async {
      String? renamed;
      await tester.pumpObers(
        OiRenameDialog(
          file: const OiFileNodeData(
            id: '1',
            name: 'report.pdf',
            folder: false,
          ),
          onRename: (name) => renamed = name,
        ),
      );
      // Name is still 'report.pdf', tapping Rename should not fire
      await tester.tap(
        find.widgetWithText(OiButton, 'Rename'),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(renamed, isNull);
    });

    testWidgets('tapping Cancel fires onCancel', (tester) async {
      var cancelled = false;
      await tester.pumpObers(
        OiRenameDialog(
          file: const OiFileNodeData(
            id: '1',
            name: 'report.pdf',
            folder: false,
          ),
          onRename: (_) {},
          onCancel: () => cancelled = true,
        ),
      );
      await tester.tap(find.widgetWithText(OiButton, 'Cancel'));
      await tester.pump();
      expect(cancelled, isTrue);
    });

    testWidgets('ESC key fires onCancel', (tester) async {
      var cancelled = false;
      await tester.pumpObers(
        OiRenameDialog(
          file: const OiFileNodeData(
            id: '1',
            name: 'report.pdf',
            folder: false,
          ),
          onRename: (_) {},
          onCancel: () => cancelled = true,
        ),
      );
      final kl = tester.widget<KeyboardListener>(find.byType(KeyboardListener));
      kl.focusNode.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(cancelled, isTrue);
    });

    testWidgets('has correct semantics label', (tester) async {
      await tester.pumpObers(
        OiRenameDialog(
          file: const OiFileNodeData(
            id: '1',
            name: 'report.pdf',
            folder: false,
          ),
          onRename: (_) {},
        ),
      );
      expect(find.bySemanticsLabel(RegExp('Rename dialog')), findsOneWidget);
    });

    testWidgets('renders for folder files', (tester) async {
      await tester.pumpObers(
        OiRenameDialog(
          file: const OiFileNodeData(
            id: '1',
            name: 'Documents',
            folder: true,
          ),
          onRename: (_) {},
        ),
      );
      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('Rename'), findsAtLeast(1));
    });
  });
}
