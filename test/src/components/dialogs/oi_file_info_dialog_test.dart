// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/dialogs/oi_file_info_dialog.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiFileInfoDialog', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpObers(
        const OiFileInfoDialog(
          file: OiFileNodeData(id: '1', name: 'report.pdf', isFolder: false),
        ),
      );
      expect(find.byType(OiFileInfoDialog), findsOneWidget);
    });

    testWidgets('displays file name', (tester) async {
      await tester.pumpObers(
        const OiFileInfoDialog(
          file: OiFileNodeData(id: '1', name: 'report.pdf', isFolder: false),
        ),
      );
      expect(find.text('report.pdf'), findsOneWidget);
    });

    testWidgets('displays Folder type for folders', (tester) async {
      await tester.pumpObers(
        const OiFileInfoDialog(
          file: OiFileNodeData(id: '1', name: 'Documents', isFolder: true),
        ),
      );
      expect(find.text('Folder'), findsOneWidget);
    });

    testWidgets('displays file size when provided', (tester) async {
      await tester.pumpObers(
        const OiFileInfoDialog(
          file: OiFileNodeData(
            id: '1',
            name: 'report.pdf',
            isFolder: false,
            size: 2048,
          ),
        ),
      );
      expect(find.text('Size'), findsOneWidget);
      expect(find.text('2.0 KB'), findsOneWidget);
    });

    testWidgets('displays created date when provided', (tester) async {
      await tester.pumpObers(
        OiFileInfoDialog(
          file: OiFileNodeData(
            id: '1',
            name: 'notes.txt',
            isFolder: false,
            created: DateTime(2024, 3, 15, 10, 30),
          ),
        ),
      );
      expect(find.text('Created'), findsOneWidget);
      expect(find.text('March 15, 2024 at 10:30'), findsOneWidget);
    });

    testWidgets('displays modified date when provided', (tester) async {
      await tester.pumpObers(
        OiFileInfoDialog(
          file: OiFileNodeData(
            id: '1',
            name: 'notes.txt',
            isFolder: false,
            modified: DateTime(2024, 6, 1, 14, 5),
          ),
        ),
      );
      expect(find.text('Modified'), findsOneWidget);
      expect(find.text('June 1, 2024 at 14:05'), findsOneWidget);
    });

    testWidgets('displays item count for folders', (tester) async {
      await tester.pumpObers(
        const OiFileInfoDialog(
          file: OiFileNodeData(
            id: '1',
            name: 'Photos',
            isFolder: true,
            itemCount: 57,
          ),
        ),
      );
      expect(find.text('Items'), findsOneWidget);
      expect(find.text('57'), findsOneWidget);
    });

    testWidgets('displays extra metadata when provided', (tester) async {
      await tester.pumpObers(
        const OiFileInfoDialog(
          file: OiFileNodeData(id: '1', name: 'doc.pdf', isFolder: false),
          extraMetadata: {'Author': 'Jane', 'Version': '2.1'},
        ),
      );
      expect(find.text('Author'), findsOneWidget);
      expect(find.text('Jane'), findsOneWidget);
      expect(find.text('Version'), findsOneWidget);
      expect(find.text('2.1'), findsOneWidget);
    });

    testWidgets('hides extra metadata section when null', (tester) async {
      await tester.pumpObers(
        const OiFileInfoDialog(
          file: OiFileNodeData(id: '1', name: 'doc.pdf', isFolder: false),
        ),
      );
      expect(find.text('Author'), findsNothing);
    });

    testWidgets('tapping Close fires onClose', (tester) async {
      var closed = false;
      await tester.pumpObers(
        OiFileInfoDialog(
          file: const OiFileNodeData(id: '1', name: 'doc.pdf', isFolder: false),
          onClose: () => closed = true,
        ),
      );
      await tester.tap(find.widgetWithText(OiButton, 'Close'));
      await tester.pump();
      expect(closed, isTrue);
    });

    testWidgets('has correct semantics label', (tester) async {
      await tester.pumpObers(
        const OiFileInfoDialog(
          file: OiFileNodeData(id: '1', name: 'doc.pdf', isFolder: false),
        ),
      );
      expect(find.bySemanticsLabel(RegExp('File info dialog')), findsOneWidget);
    });

    testWidgets('hides size row for folders', (tester) async {
      await tester.pumpObers(
        const OiFileInfoDialog(
          file: OiFileNodeData(
            id: '1',
            name: 'Docs',
            isFolder: true,
            size: 1024,
          ),
        ),
      );
      expect(find.text('Size'), findsNothing);
    });

    testWidgets('displays location when parentId is set', (tester) async {
      await tester.pumpObers(
        const OiFileInfoDialog(
          file: OiFileNodeData(
            id: '1',
            name: 'notes.txt',
            isFolder: false,
            parentId: '/home/docs',
          ),
        ),
      );
      expect(find.text('Location'), findsOneWidget);
      expect(find.text('/home/docs'), findsOneWidget);
    });
  });
}
