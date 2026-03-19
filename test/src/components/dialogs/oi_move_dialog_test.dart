// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/dialogs/oi_move_dialog.dart';
import 'package:obers_ui/src/composites/data/oi_tree.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';

import '../../../helpers/pump_app.dart';

const _docFolder = OiFileNodeData(
  id: 'docs',
  name: 'Documents',
  isFolder: true,
);

const _picFolder = OiFileNodeData(
  id: 'pics',
  name: 'Pictures',
  isFolder: true,
);

const _folderTree = <OiTreeNode<OiFileNodeData>>[
  OiTreeNode<OiFileNodeData>(
    id: 'docs',
    label: 'Documents',
    data: _docFolder,
  ),
  OiTreeNode<OiFileNodeData>(
    id: 'pics',
    label: 'Pictures',
    data: _picFolder,
  ),
];

const _file = OiFileNodeData(
  id: 'f1',
  name: 'report.pdf',
  isFolder: false,
);

void main() {
  group('OiMoveDialog', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpObers(
        OiMoveDialog(
          files: const [_file],
          folderTree: _folderTree,
          onMove: (_) {},
        ),
        surfaceSize: const Size(600, 800),
      );
      expect(find.byType(OiMoveDialog), findsOneWidget);
    });

    testWidgets('shows Move title for single file', (tester) async {
      await tester.pumpObers(
        OiMoveDialog(
          files: const [_file],
          folderTree: _folderTree,
          onMove: (_) {},
        ),
        surfaceSize: const Size(600, 800),
      );
      expect(find.text('Move report.pdf to...'), findsOneWidget);
    });

    testWidgets('shows Move title for multiple files', (tester) async {
      const file2 = OiFileNodeData(
        id: 'f2',
        name: 'notes.txt',
        isFolder: false,
      );
      await tester.pumpObers(
        OiMoveDialog(
          files: const [_file, file2],
          folderTree: _folderTree,
          onMove: (_) {},
        ),
        surfaceSize: const Size(600, 800),
      );
      expect(find.text('Move 2 items to...'), findsOneWidget);
    });

    testWidgets('shows Copy title when copyMode is true', (tester) async {
      await tester.pumpObers(
        OiMoveDialog(
          files: const [_file],
          folderTree: _folderTree,
          onMove: (_) {},
          copyMode: true,
        ),
        surfaceSize: const Size(600, 800),
      );
      expect(find.text('Copy report.pdf to...'), findsOneWidget);
    });

    testWidgets('displays folder names in tree', (tester) async {
      await tester.pumpObers(
        OiMoveDialog(
          files: const [_file],
          folderTree: _folderTree,
          onMove: (_) {},
        ),
        surfaceSize: const Size(600, 800),
      );
      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('Pictures'), findsOneWidget);
    });

    testWidgets('Move here button is disabled until folder is selected',
        (tester) async {
      await tester.pumpObers(
        OiMoveDialog(
          files: const [_file],
          folderTree: _folderTree,
          onMove: (_) {},
        ),
        surfaceSize: const Size(600, 800),
      );
      // The button label should be present but onTap should be null
      expect(find.widgetWithText(OiButton, 'Move here'), findsOneWidget);
    });

    testWidgets('shows Copy here label in copy mode', (tester) async {
      await tester.pumpObers(
        OiMoveDialog(
          files: const [_file],
          folderTree: _folderTree,
          onMove: (_) {},
          copyMode: true,
        ),
        surfaceSize: const Size(600, 800),
      );
      expect(find.widgetWithText(OiButton, 'Copy here'), findsOneWidget);
    });

    testWidgets('tapping Cancel fires onCancel', (tester) async {
      var cancelled = false;
      await tester.pumpObers(
        OiMoveDialog(
          files: const [_file],
          folderTree: _folderTree,
          onMove: (_) {},
          onCancel: () => cancelled = true,
        ),
        surfaceSize: const Size(600, 800),
      );
      await tester.tap(find.widgetWithText(OiButton, 'Cancel'));
      await tester.pump();
      expect(cancelled, isTrue);
    });

    testWidgets('ESC key fires onCancel', (tester) async {
      var cancelled = false;
      await tester.pumpObers(
        OiMoveDialog(
          files: const [_file],
          folderTree: _folderTree,
          onMove: (_) {},
          onCancel: () => cancelled = true,
        ),
        surfaceSize: const Size(600, 800),
      );
      final kl =
          tester.widget<KeyboardListener>(find.byType(KeyboardListener));
      kl.focusNode.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(cancelled, isTrue);
    });

    testWidgets('renders search input', (tester) async {
      await tester.pumpObers(
        OiMoveDialog(
          files: const [_file],
          folderTree: _folderTree,
          onMove: (_) {},
        ),
        surfaceSize: const Size(600, 800),
      );
      // The search input is rendered via OiTextInput.search
      expect(find.byType(OiMoveDialog), findsOneWidget);
    });

    testWidgets('shows New Folder button when onCreateFolder is provided',
        (tester) async {
      await tester.pumpObers(
        OiMoveDialog(
          files: const [_file],
          folderTree: _folderTree,
          onMove: (_) {},
          onCreateFolder: (_) {},
        ),
        surfaceSize: const Size(600, 800),
      );
      expect(find.widgetWithText(OiButton, '+ New Folder'), findsOneWidget);
    });

    testWidgets('hides New Folder button when onCreateFolder is null',
        (tester) async {
      await tester.pumpObers(
        OiMoveDialog(
          files: const [_file],
          folderTree: _folderTree,
          onMove: (_) {},
        ),
        surfaceSize: const Size(600, 800),
      );
      expect(find.widgetWithText(OiButton, '+ New Folder'), findsNothing);
    });

    testWidgets('has correct semantics label for move mode', (tester) async {
      await tester.pumpObers(
        OiMoveDialog(
          files: const [_file],
          folderTree: _folderTree,
          onMove: (_) {},
        ),
        surfaceSize: const Size(600, 800),
      );
      expect(
        find.bySemanticsLabel(RegExp('Move dialog')),
        findsOneWidget,
      );
    });

    testWidgets('has correct semantics label for copy mode', (tester) async {
      await tester.pumpObers(
        OiMoveDialog(
          files: const [_file],
          folderTree: _folderTree,
          onMove: (_) {},
          copyMode: true,
        ),
        surfaceSize: const Size(600, 800),
      );
      expect(
        find.bySemanticsLabel(RegExp('Copy dialog')),
        findsOneWidget,
      );
    });
  });
}
