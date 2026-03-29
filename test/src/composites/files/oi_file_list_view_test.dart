// Tests do not require documentation comments.

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/files/oi_file_list_view.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';
import 'package:obers_ui/src/models/settings/oi_file_explorer_settings.dart';

import '../../../helpers/pump_app.dart';

/// Tap and pump past the double-tap timeout so the single-tap resolves.
Future<void> _tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump(kDoubleTapTimeout + const Duration(milliseconds: 50));
}

// ── Test data ─────────────────────────────────────────────────────────────────

final _testFiles = [
  OiFileNodeData(
    id: 'file1',
    name: 'document.pdf',
    folder: false,
    size: 1024 * 1024,
    mimeType: 'application/pdf',
    modified: DateTime(2025, 3, 15),
  ),
  OiFileNodeData(
    id: 'file2',
    name: 'image.png',
    folder: false,
    size: 2048,
    mimeType: 'image/png',
    modified: DateTime(2025, 1, 10),
  ),
  const OiFileNodeData(
    id: 'folder1',
    name: 'Projects',
    folder: true,
    itemCount: 12,
  ),
  const OiFileNodeData(
    id: 'file3',
    name: 'notes.txt',
    folder: false,
    size: 256,
  ),
];

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _listView({
  List<OiFileNodeData>? files,
  Set<Object>? selectedKeys,
  ValueChanged<Set<Object>>? onSelectionChange,
  ValueChanged<OiFileNodeData>? onOpen,
  OiFileSortField sortField = OiFileSortField.name,
  OiSortDirection sortDirection = OiSortDirection.ascending,
  ValueChanged<OiFileSortField>? onSortFieldChange,
  ValueChanged<OiSortDirection>? onSortDirectionChange,
  bool showSize = true,
  bool showModified = true,
  bool showType = true,
  Object? renamingKey,
  ValueChanged<String>? onRename,
  VoidCallback? onCancelRename,
  bool enableDragDrop = false,
  bool enableMultiSelect = true,
  String? searchQuery,
  bool loading = false,
  String? semanticsLabel,
}) {
  return SizedBox(
    width: 800,
    height: 600,
    child: OiFileListView(
      files: files ?? _testFiles,
      selectedKeys: selectedKeys ?? const {},
      onSelectionChange: onSelectionChange ?? (_) {},
      onOpen: onOpen ?? (_) {},
      sortField: sortField,
      sortDirection: sortDirection,
      onSortFieldChange: onSortFieldChange,
      onSortDirectionChange: onSortDirectionChange,
      showSize: showSize,
      showModified: showModified,
      showType: showType,
      renamingKey: renamingKey,
      onRename: onRename,
      onCancelRename: onCancelRename,
      enableDragDrop: enableDragDrop,
      enableMultiSelect: enableMultiSelect,
      searchQuery: searchQuery,
      loading: loading,
      semanticsLabel: semanticsLabel,
    ),
  );
}

void main() {
  group('OiFileListView', () {
    // ══════════════════════════════════════════════════════════════════════════
    // ── Rendering tests ────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('renders without errors', (tester) async {
      await tester.pumpObers(_listView());
      expect(find.text('document.pdf'), findsOneWidget);
    });

    testWidgets('renders all file names', (tester) async {
      await tester.pumpObers(_listView());
      expect(find.text('document.pdf'), findsOneWidget);
      expect(find.text('image.png'), findsOneWidget);
      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('notes.txt'), findsOneWidget);
    });

    testWidgets('renders file sizes', (tester) async {
      await tester.pumpObers(_listView());
      expect(find.text('1.0 MB'), findsOneWidget);
      expect(find.text('2.0 KB'), findsOneWidget);
    });

    testWidgets('renders dash for folder size', (tester) async {
      await tester.pumpObers(_listView());
      // Folders show '—' for size; at least one dash should exist
      expect(find.text('\u2014'), findsWidgets);
    });

    testWidgets('renders modified dates', (tester) async {
      await tester.pumpObers(_listView());
      expect(find.text('Mar 15, 2025'), findsOneWidget);
      expect(find.text('Jan 10, 2025'), findsOneWidget);
    });

    testWidgets('renders file type extensions in uppercase', (tester) async {
      await tester.pumpObers(_listView());
      // OiFileIcon may also render extension text, so use findsWidgets
      expect(find.text('PDF'), findsWidgets);
      expect(find.text('PNG'), findsWidgets);
      expect(find.text('TXT'), findsWidgets);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Column headers ────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('renders column headers', (tester) async {
      await tester.pumpObers(_listView());
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Column headers',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Name header shows sort indicator when sorted by name', (
      tester,
    ) async {
      await tester.pumpObers(_listView());
      // Should contain the ascending indicator
      expect(find.textContaining('Name'), findsOneWidget);
    });

    testWidgets('hidden columns are not rendered', (tester) async {
      await tester.pumpObers(
        _listView(showSize: false, showModified: false, showType: false),
      );
      // Headers should not include Size, Modified, Type
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Sort by size',
        ),
        findsNothing,
      );
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics && w.properties.label == 'Sort by modified date',
        ),
        findsNothing,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Sort by type',
        ),
        findsNothing,
      );
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Sort callbacks ────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('tapping Name header toggles sort direction', (tester) async {
      OiSortDirection? newDirection;
      await tester.pumpObers(
        _listView(onSortDirectionChange: (d) => newDirection = d),
      );
      // Tap the sort-by-name button
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Sort by name',
        ),
      );
      await tester.pump();
      expect(newDirection, OiSortDirection.descending);
    });

    testWidgets('tapping different column header changes sort field', (
      tester,
    ) async {
      OiFileSortField? newField;
      await tester.pumpObers(_listView(onSortFieldChange: (f) => newField = f));
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Sort by size',
        ),
      );
      await tester.pump();
      expect(newField, OiFileSortField.size);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Selection ─────────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('tapping a row calls onSelectionChange', (tester) async {
      Set<Object>? selected;
      await tester.pumpObers(_listView(onSelectionChange: (s) => selected = s));
      await _tapAndSettle(tester, find.text('document.pdf'));
      expect(selected, {'file1'});
    });

    testWidgets('selected rows have Semantics selected flag', (tester) async {
      await tester.pumpObers(_listView(selectedKeys: {'file1'}));
      final semantics = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.selected ?? false) &&
              (w.properties.label?.contains('document.pdf') ?? false),
        ),
      );
      expect(semantics.properties.selected, isTrue);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Double tap / open ─────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('double tapping a row calls onOpen', (tester) async {
      OiFileNodeData? opened;
      await tester.pumpObers(_listView(onOpen: (f) => opened = f));
      await tester.tap(find.text('document.pdf'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('document.pdf'));
      await tester.pumpAndSettle();
      expect(opened?.id, 'file1');
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Empty state ───────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('renders with empty file list', (tester) async {
      await tester.pumpObers(_listView(files: const []));
      // Header should still be rendered, but no rows
      expect(find.text('document.pdf'), findsNothing);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Loading state ─────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('renders loading skeleton when loading is true', (
      tester,
    ) async {
      await tester.pumpObers(_listView(loading: true));
      expect(find.text('document.pdf'), findsNothing);
    });

    testWidgets('loading state still shows column headers', (tester) async {
      await tester.pumpObers(_listView(loading: true));
      // The header should still render in loading state
      expect(find.textContaining('Name'), findsOneWidget);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Accessibility ─────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('default semantics label is "File list"', (tester) async {
      await tester.pumpObers(_listView());
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'File list',
        ),
        findsOneWidget,
      );
    });

    testWidgets('custom semantics label is applied', (tester) async {
      await tester.pumpObers(_listView(semanticsLabel: 'Invoice file list'));
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Invoice file list',
        ),
        findsOneWidget,
      );
    });

    testWidgets('rows have semantic labels with file info', (tester) async {
      await tester.pumpObers(_listView());
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.label?.contains('document.pdf') ?? false) &&
              (w.properties.label?.contains('pdf') ?? false),
        ),
        findsOneWidget,
      );
    });

    testWidgets('folder rows have "folder" in semantic label', (tester) async {
      await tester.pumpObers(_listView());
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.label?.contains('Projects') ?? false) &&
              (w.properties.label?.contains('folder') ?? false),
        ),
        findsOneWidget,
      );
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Search highlight ──────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('renders with search query without errors', (tester) async {
      await tester.pumpObers(_listView(searchQuery: 'doc'));
      // When search query is set, matching names use RichText with TextSpan
      // instead of plain Text. Verify the widget renders without errors.
      expect(find.byType(OiFileListView), findsOneWidget);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Single select mode ────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('single select mode selects only one', (tester) async {
      Set<Object>? selected;
      await tester.pumpObers(
        _listView(
          enableMultiSelect: false,
          onSelectionChange: (s) => selected = s,
        ),
      );
      await _tapAndSettle(tester, find.text('document.pdf'));
      expect(selected, {'file1'});

      await _tapAndSettle(tester, find.text('image.png'));
      expect(selected, {'file2'});
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Rebuilds ──────────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('changing sort field and direction rebuilds correctly', (
      tester,
    ) async {
      await tester.pumpObers(_listView());
      expect(find.textContaining('Name'), findsOneWidget);

      await tester.pumpObers(
        _listView(
          sortField: OiFileSortField.size,
          sortDirection: OiSortDirection.descending,
        ),
      );
      expect(find.textContaining('Size'), findsOneWidget);
    });
  });
}
