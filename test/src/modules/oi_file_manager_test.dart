// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/modules/oi_file_manager.dart';

import '../../helpers/pump_app.dart';

void main() {
  OiFileNode _file({
    Object key = 'f1',
    String name = 'readme.txt',
    int? size = 1024,
  }) {
    return OiFileNode(key: key, name: name, folder: false, size: size);
  }

  OiFileNode _folder({Object key = 'd1', String name = 'Documents'}) {
    return OiFileNode(key: key, name: name, folder: true);
  }

  testWidgets('files render their names in grid layout', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 500,
        height: 600,
        child: OiFileManager(
          items: [_file(name: 'report.pdf')],
          label: 'Files',
          layout: OiFileManagerLayout.grid,
        ),
      ),
    );
    expect(find.text('report.pdf'), findsOneWidget);
  });

  testWidgets('files render their names in list layout', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 500,
        height: 600,
        child: OiFileManager(
          items: [_file(name: 'data.csv')],
          label: 'Files',
          layout: OiFileManagerLayout.list,
        ),
      ),
    );
    expect(find.text('data.csv'), findsOneWidget);
  });

  testWidgets('folders render with folder icon', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 500,
        height: 600,
        child: OiFileManager(
          items: [_folder(name: 'Photos')],
          label: 'Files',
          layout: OiFileManagerLayout.grid,
        ),
      ),
    );
    expect(find.text('Photos'), findsOneWidget);
    // Folder icon (0xe2c7)
    expect(
      find.byIcon(const IconData(0xe2c7, fontFamily: 'MaterialIcons')),
      findsOneWidget,
    );
  });

  testWidgets('onOpen fires on double-tap', (tester) async {
    OiFileNode? opened;
    final file = _file(name: 'notes.txt');

    await tester.pumpObers(
      SizedBox(
        width: 500,
        height: 600,
        child: OiFileManager(
          items: [file],
          label: 'Files',
          layout: OiFileManagerLayout.grid,
          onOpen: (node) => opened = node,
        ),
      ),
    );

    await tester.tap(find.text('notes.txt'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('notes.txt'));
    await tester.pumpAndSettle();

    expect(opened?.name, 'notes.txt');
  });

  testWidgets('grid layout uses GridView', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 500,
        height: 600,
        child: OiFileManager(
          items: [_file()],
          label: 'Files',
          layout: OiFileManagerLayout.grid,
        ),
      ),
    );
    expect(find.byType(GridView), findsOneWidget);
  });

  testWidgets('list layout uses ListView', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 500,
        height: 600,
        child: OiFileManager(
          items: [_file()],
          label: 'Files',
          layout: OiFileManagerLayout.list,
        ),
      ),
    );
    // ListView is used for list layout
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('current path shows as breadcrumbs', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 500,
        height: 600,
        child: OiFileManager(
          items: const [],
          label: 'Files',
          currentPath: const ['Documents', 'Work'],
        ),
      ),
    );
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Documents'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
  });

  testWidgets('empty folder shows empty state', (tester) async {
    await tester.pumpObers(
      const SizedBox(
        width: 500,
        height: 600,
        child: OiFileManager(items: [], label: 'Files'),
      ),
    );
    expect(find.text('This folder is empty'), findsOneWidget);
  });

  testWidgets('has semantics label', (tester) async {
    await tester.pumpObers(
      const SizedBox(
        width: 500,
        height: 600,
        child: OiFileManager(items: [], label: 'Project Files'),
      ),
    );
    expect(find.bySemanticsLabel('Project Files'), findsOneWidget);
  });

  testWidgets('file size renders in list layout', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 500,
        height: 600,
        child: OiFileManager(
          items: [_file(name: 'big.zip', size: 2048)],
          label: 'Files',
          layout: OiFileManagerLayout.list,
        ),
      ),
    );
    expect(find.text('2.0 KB'), findsOneWidget);
  });
}
