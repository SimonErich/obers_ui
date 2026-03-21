// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_empty_state.dart';
import 'package:obers_ui/src/components/display/oi_file_grid_card.dart';
import 'package:obers_ui/src/components/display/oi_file_tile.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/modules/oi_file_manager.dart';

import '../../helpers/pump_app.dart';

void main() {
  OiFileNode file0({
    Object key = 'f1',
    String name = 'readme.txt',
    int? size = 1024,
  }) {
    return OiFileNode(key: key, name: name, folder: false, size: size);
  }

  OiFileNode folder({Object key = 'd1', String name = 'Documents'}) {
    return OiFileNode(key: key, name: name, folder: true);
  }

  testWidgets('files render their names in grid layout', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 500,
        height: 600,
        child: OiFileManager(
          items: [file0(name: 'report.pdf')],
          label: 'Files',
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
          items: [file0(name: 'data.csv')],
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
          items: [folder(name: 'Photos')],
          label: 'Files',
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
    final file = file0(name: 'notes.txt');

    await tester.pumpObers(
      SizedBox(
        width: 500,
        height: 600,
        child: OiFileManager(
          items: [file],
          label: 'Files',
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
        child: OiFileManager(items: [file0()], label: 'Files'),
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
          items: [file0()],
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
      const SizedBox(
        width: 500,
        height: 600,
        child: OiFileManager(
          items: [],
          label: 'Files',
          currentPath: ['Documents', 'Work'],
        ),
      ),
    );
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Documents'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
  });

  testWidgets('empty folder shows OiEmptyState with folder icon', (
    tester,
  ) async {
    await tester.pumpObers(
      const SizedBox(
        width: 500,
        height: 600,
        child: OiFileManager(items: [], label: 'Files'),
      ),
    );
    expect(find.byType(OiEmptyState), findsOneWidget);
    expect(find.text('This folder is empty'), findsOneWidget);
    expect(
      find.byIcon(const IconData(0xe2c7, fontFamily: 'MaterialIcons')),
      findsOneWidget,
    );
  });

  testWidgets('empty folder shows Upload button when onUpload is set', (
    tester,
  ) async {
    var uploadCalled = false;
    await tester.pumpObers(
      SizedBox(
        width: 500,
        height: 600,
        child: OiFileManager(
          items: const [],
          label: 'Files',
          onUpload: (_) => uploadCalled = true,
        ),
      ),
    );
    expect(find.byType(OiEmptyState), findsOneWidget);
    expect(find.text('Upload files'), findsOneWidget);
    expect(find.byType(OiButton), findsOneWidget);

    await tester.tap(find.text('Upload files'));
    await tester.pumpAndSettle();
    expect(uploadCalled, isTrue);
  });

  testWidgets('empty folder hides Upload button when onUpload is null', (
    tester,
  ) async {
    await tester.pumpObers(
      const SizedBox(
        width: 500,
        height: 600,
        child: OiFileManager(items: [], label: 'Files'),
      ),
    );
    expect(find.byType(OiEmptyState), findsOneWidget);
    expect(find.text('Upload files'), findsNothing);
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
          items: [file0(name: 'big.zip', size: 2048)],
          label: 'Files',
          layout: OiFileManagerLayout.list,
        ),
      ),
    );
    expect(find.text('2.0 KB'), findsOneWidget);
  });

  // ── Search filtering (REQ-0990) ─────────────────────────────────────────

  group('Search filtering (REQ-0990)', () {
    testWidgets('filters items by name case-insensitively in list layout', (
      tester,
    ) async {
      await tester.pumpObers(
        SizedBox(
          width: 500,
          height: 600,
          child: OiFileManager(
            items: [
              file0(key: 'a', name: 'report.pdf'),
              file0(key: 'b', name: 'notes.txt'),
              folder(key: 'c', name: 'Reports'),
            ],
            label: 'Files',
            layout: OiFileManagerLayout.list,
            searchQuery: 'report',
          ),
        ),
      );

      expect(find.text('report.pdf'), findsOneWidget);
      expect(find.text('Reports'), findsOneWidget);
      expect(find.text('notes.txt'), findsNothing);
    });

    testWidgets('filters items by name case-insensitively in grid layout', (
      tester,
    ) async {
      await tester.pumpObers(
        SizedBox(
          width: 500,
          height: 600,
          child: OiFileManager(
            items: [
              file0(key: 'a', name: 'photo.jpg'),
              file0(key: 'b', name: 'image.png'),
              file0(key: 'c', name: 'PHOTO_2.jpg'),
            ],
            label: 'Files',
            searchQuery: 'photo',
          ),
        ),
      );

      expect(find.text('photo.jpg'), findsOneWidget);
      expect(find.text('PHOTO_2.jpg'), findsOneWidget);
      expect(find.text('image.png'), findsNothing);
    });

    testWidgets('shows all items when searchQuery is null', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 500,
          height: 600,
          child: OiFileManager(
            items: [
              file0(key: 'a', name: 'one.txt'),
              file0(key: 'b', name: 'two.txt'),
            ],
            label: 'Files',
            layout: OiFileManagerLayout.list,
          ),
        ),
      );

      expect(find.text('one.txt'), findsOneWidget);
      expect(find.text('two.txt'), findsOneWidget);
    });

    testWidgets('shows all items when searchQuery is empty', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 500,
          height: 600,
          child: OiFileManager(
            items: [
              file0(key: 'a', name: 'one.txt'),
              file0(key: 'b', name: 'two.txt'),
            ],
            label: 'Files',
            layout: OiFileManagerLayout.list,
            searchQuery: '',
          ),
        ),
      );

      expect(find.text('one.txt'), findsOneWidget);
      expect(find.text('two.txt'), findsOneWidget);
    });

    testWidgets('shows empty state when no items match search', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 500,
          height: 600,
          child: OiFileManager(
            items: [file0(key: 'a', name: 'report.pdf')],
            label: 'Files',
            layout: OiFileManagerLayout.list,
            searchQuery: 'xyz',
          ),
        ),
      );

      expect(find.text('report.pdf'), findsNothing);
      expect(find.text('This folder is empty'), findsOneWidget);
    });
  });

  // ── Uses OiFileTile and OiFileGridCard ──────────────────────────────────

  group('Uses new tile components', () {
    testWidgets('list layout renders OiFileTile widgets', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 500,
          height: 600,
          child: OiFileManager(
            items: [file0(name: 'data.csv')],
            label: 'Files',
            layout: OiFileManagerLayout.list,
          ),
        ),
      );

      expect(find.byType(OiFileTile), findsOneWidget);
    });

    testWidgets('grid layout renders OiFileGridCard widgets', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 500,
          height: 600,
          child: OiFileManager(
            items: [file0(name: 'data.csv')],
            label: 'Files',
          ),
        ),
      );

      expect(find.byType(OiFileGridCard), findsOneWidget);
    });

    testWidgets('searchQuery is passed to OiFileTile for highlighting', (
      tester,
    ) async {
      await tester.pumpObers(
        SizedBox(
          width: 500,
          height: 600,
          child: OiFileManager(
            items: [file0(name: 'report.pdf')],
            label: 'Files',
            layout: OiFileManagerLayout.list,
            searchQuery: 'port',
          ),
        ),
      );

      final tile = tester.widget<OiFileTile>(find.byType(OiFileTile));
      expect(tile.searchQuery, 'port');
    });

    testWidgets('searchQuery is passed to OiFileGridCard for highlighting', (
      tester,
    ) async {
      await tester.pumpObers(
        SizedBox(
          width: 500,
          height: 600,
          child: OiFileManager(
            items: [file0(name: 'report.pdf')],
            label: 'Files',
            searchQuery: 'port',
          ),
        ),
      );

      final card = tester.widget<OiFileGridCard>(find.byType(OiFileGridCard));
      expect(card.searchQuery, 'port');
    });
  });

  // ── Search input & debounce (REQ-0989) ──────────────────────────────────

  group('Search input and debounce (REQ-0989)', () {
    testWidgets('renders search input when onSearch is provided', (
      tester,
    ) async {
      await tester.pumpObers(
        SizedBox(
          width: 500,
          height: 600,
          child: OiFileManager(
            items: [file0()],
            label: 'Files',
            onSearch: (_) {},
          ),
        ),
      );

      expect(find.byType(OiTextInput), findsOneWidget);
    });

    testWidgets('does not render search input when onSearch is null', (
      tester,
    ) async {
      await tester.pumpObers(
        SizedBox(
          width: 500,
          height: 600,
          child: OiFileManager(items: [file0()], label: 'Files'),
        ),
      );

      expect(find.byType(OiTextInput), findsNothing);
    });

    testWidgets('debounces non-empty keystrokes for 300ms', (tester) async {
      final calls = <String>[];

      await tester.pumpObers(
        SizedBox(
          width: 500,
          height: 600,
          child: OiFileManager(
            items: [file0()],
            label: 'Files',
            onSearch: calls.add,
          ),
        ),
      );

      // Type rapidly — each character within the debounce window.
      await tester.enterText(find.byType(OiTextInput), 'a');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(OiTextInput), 'ab');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(OiTextInput), 'abc');
      await tester.pump(const Duration(milliseconds: 100));

      // Still within the 300 ms window — callback should not have fired for
      // non-empty queries.
      expect(calls.where((q) => q.isNotEmpty), isEmpty);

      // Wait for debounce to elapse.
      await tester.pump(const Duration(milliseconds: 300));

      expect(calls.where((q) => q.isNotEmpty).toList(), ['abc']);
    });

    testWidgets('fires immediately when query is cleared', (tester) async {
      final calls = <String>[];

      await tester.pumpObers(
        SizedBox(
          width: 500,
          height: 600,
          child: OiFileManager(
            items: [file0()],
            label: 'Files',
            onSearch: calls.add,
          ),
        ),
      );

      // Type then clear.
      await tester.enterText(find.byType(OiTextInput), 'abc');
      await tester.pump(const Duration(milliseconds: 300));
      calls.clear();

      await tester.enterText(find.byType(OiTextInput), '');
      await tester.pump();

      // Empty query fires immediately, no debounce wait needed.
      expect(calls, ['']);
    });

    testWidgets('rapid keystrokes trigger only one callback after debounce', (
      tester,
    ) async {
      final calls = <String>[];

      await tester.pumpObers(
        SizedBox(
          width: 500,
          height: 600,
          child: OiFileManager(
            items: [file0()],
            label: 'Files',
            onSearch: calls.add,
          ),
        ),
      );

      // Simulate rapid typing.
      await tester.enterText(find.byType(OiTextInput), 'r');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.enterText(find.byType(OiTextInput), 're');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.enterText(find.byType(OiTextInput), 'rep');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.enterText(find.byType(OiTextInput), 'repo');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.enterText(find.byType(OiTextInput), 'repor');
      await tester.pump(const Duration(milliseconds: 50));
      await tester.enterText(find.byType(OiTextInput), 'report');
      await tester.pump(const Duration(milliseconds: 300));

      // Only the final value should have been emitted.
      expect(calls.where((q) => q.isNotEmpty).toList(), ['report']);
    });
  });

  // ── Server-side search (REQ-0992) ─────────────────────────────────────

  group('Server-side search (REQ-0992)', () {
    testWidgets('does not client-side filter when onSearch is provided', (
      tester,
    ) async {
      // Simulate a backend that returns a result whose name does NOT
      // contain the query (e.g. fuzzy / semantic match).
      await tester.pumpObers(
        SizedBox(
          width: 500,
          height: 600,
          child: OiFileManager(
            items: [file0(key: 'a', name: 'annual_summary.pdf')],
            label: 'Files',
            layout: OiFileManagerLayout.list,
            onSearch: (_) {},
            searchQuery: 'report',
          ),
        ),
      );

      // Item is visible even though its name does not contain the query,
      // because the consumer (server) already filtered the list.
      expect(find.text('annual_summary.pdf'), findsOneWidget);
    });

    testWidgets(
      'still highlights searchQuery in tiles for server-side search',
      (tester) async {
        await tester.pumpObers(
          SizedBox(
            width: 500,
            height: 600,
            child: OiFileManager(
              items: [file0(key: 'a', name: 'report.pdf')],
              label: 'Files',
              layout: OiFileManagerLayout.list,
              onSearch: (_) {},
              searchQuery: 'port',
            ),
          ),
        );

        final tile = tester.widget<OiFileTile>(find.byType(OiFileTile));
        expect(tile.searchQuery, 'port');
      },
    );

    testWidgets('consumer re-provides filtered items after onSearch callback', (
      tester,
    ) async {
      final allFiles = [
        file0(key: 'a', name: 'report.pdf'),
        file0(key: 'b', name: 'notes.txt'),
        file0(key: 'c', name: 'image.png'),
      ];

      // Initial state: all items, no query.
      await tester.pumpObers(
        SizedBox(
          width: 500,
          height: 600,
          child: OiFileManager(
            items: allFiles,
            label: 'Files',
            layout: OiFileManagerLayout.list,
            onSearch: (_) {},
          ),
        ),
      );

      expect(find.text('report.pdf'), findsOneWidget);
      expect(find.text('notes.txt'), findsOneWidget);
      expect(find.text('image.png'), findsOneWidget);

      // Consumer re-provides filtered list (simulating backend response).
      final filtered = [file0(key: 'a', name: 'report.pdf')];
      await tester.pumpObers(
        SizedBox(
          width: 500,
          height: 600,
          child: OiFileManager(
            items: filtered,
            label: 'Files',
            layout: OiFileManagerLayout.list,
            onSearch: (_) {},
            searchQuery: 'report',
          ),
        ),
      );

      expect(find.text('report.pdf'), findsOneWidget);
      expect(find.text('notes.txt'), findsNothing);
      expect(find.text('image.png'), findsNothing);
    });

    testWidgets('client-side filtering still works when onSearch is null', (
      tester,
    ) async {
      await tester.pumpObers(
        SizedBox(
          width: 500,
          height: 600,
          child: OiFileManager(
            items: [
              file0(key: 'a', name: 'report.pdf'),
              file0(key: 'b', name: 'notes.txt'),
            ],
            label: 'Files',
            layout: OiFileManagerLayout.list,
            searchQuery: 'report',
          ),
        ),
      );

      expect(find.text('report.pdf'), findsOneWidget);
      expect(find.text('notes.txt'), findsNothing);
    });
  });
}
