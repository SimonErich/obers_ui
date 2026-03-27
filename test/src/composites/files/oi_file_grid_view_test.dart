// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/files/oi_file_grid_view.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';

import '../../../helpers/pump_app.dart';

/// Tap and pump past the double-tap timeout so the single-tap resolves.
Future<void> _tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump(kDoubleTapTimeout + const Duration(milliseconds: 50));
}

// ── Test data ─────────────────────────────────────────────────────────────────

final _testFiles = [
  const OiFileNodeData(
    id: 'file1',
    name: 'document.pdf',
    folder: false,
    size: 1024 * 1024,
    mimeType: 'application/pdf',
  ),
  const OiFileNodeData(
    id: 'file2',
    name: 'image.png',
    folder: false,
    size: 2048,
    mimeType: 'image/png',
  ),
  const OiFileNodeData(
    id: 'folder1',
    name: 'Documents',
    folder: true,
    itemCount: 5,
  ),
  const OiFileNodeData(
    id: 'file3',
    name: 'spreadsheet.xlsx',
    folder: false,
    size: 512000,
  ),
];

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _gridView({
  List<OiFileNodeData>? files,
  Set<Object>? selectedKeys,
  ValueChanged<Set<Object>>? onSelectionChange,
  ValueChanged<OiFileNodeData>? onOpen,
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
    child: OiFileGridView(
      files: files ?? _testFiles,
      selectedKeys: selectedKeys ?? const {},
      onSelectionChange: onSelectionChange ?? (_) {},
      onOpen: onOpen ?? (_) {},
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
  group('OiFileGridView', () {
    // ══════════════════════════════════════════════════════════════════════════
    // ── Rendering tests ────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('renders without errors', (tester) async {
      await tester.pumpObers(_gridView());
      expect(find.text('document.pdf'), findsOneWidget);
    });

    testWidgets('renders all file names', (tester) async {
      await tester.pumpObers(_gridView());
      expect(find.text('document.pdf'), findsOneWidget);
      expect(find.text('image.png'), findsOneWidget);
      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('spreadsheet.xlsx'), findsOneWidget);
    });

    testWidgets('renders folder item count', (tester) async {
      await tester.pumpObers(_gridView());
      expect(find.text('5 items'), findsOneWidget);
    });

    testWidgets('renders file size for files', (tester) async {
      await tester.pumpObers(_gridView());
      expect(find.text('1.0 MB'), findsOneWidget);
      expect(find.text('2.0 KB'), findsOneWidget);
    });

    testWidgets('renders empty folder as "Empty"', (tester) async {
      final files = [
        const OiFileNodeData(
          id: 'emptyFolder',
          name: 'Empty Folder',
          folder: true,
        ),
      ];
      await tester.pumpObers(_gridView(files: files));
      expect(find.text('Empty'), findsOneWidget);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Empty state ───────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('renders with empty file list', (tester) async {
      await tester.pumpObers(_gridView(files: const []));
      // Should render without errors (empty grid)
      expect(find.text('document.pdf'), findsNothing);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Loading state ─────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('renders loading skeleton when loading is true', (
      tester,
    ) async {
      await tester.pumpObers(_gridView(loading: true));
      // Loading state shows 8 placeholder containers, not actual file names
      expect(find.text('document.pdf'), findsNothing);
    });

    testWidgets('loading state does not show file names', (tester) async {
      await tester.pumpObers(_gridView(loading: true));
      expect(find.text('image.png'), findsNothing);
      expect(find.text('Documents'), findsNothing);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Selection ─────────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('tapping a file calls onSelectionChange', (tester) async {
      Set<Object>? selected;
      await tester.pumpObers(_gridView(onSelectionChange: (s) => selected = s));
      await _tapAndSettle(tester, find.text('document.pdf'));
      expect(selected, {'file1'});
    });

    testWidgets('tapping another file changes selection', (tester) async {
      Set<Object>? selected;
      await tester.pumpObers(_gridView(onSelectionChange: (s) => selected = s));
      await _tapAndSettle(tester, find.text('image.png'));
      expect(selected, {'file2'});
    });

    testWidgets('selected keys are visually indicated', (tester) async {
      await tester.pumpObers(_gridView(selectedKeys: {'file1'}));
      // The widget should render with the selected file highlighted.
      // We verify through Semantics that the selected flag is set.
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

    testWidgets('double tapping a file calls onOpen', (tester) async {
      OiFileNodeData? opened;
      await tester.pumpObers(_gridView(onOpen: (f) => opened = f));
      await tester.tap(find.text('document.pdf'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('document.pdf'));
      await tester.pumpAndSettle();
      expect(opened?.id, 'file1');
    });

    testWidgets('double tapping a folder calls onOpen', (tester) async {
      OiFileNodeData? opened;
      await tester.pumpObers(_gridView(onOpen: (f) => opened = f));
      await tester.tap(find.text('Documents'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Documents'));
      await tester.pumpAndSettle();
      expect(opened?.id, 'folder1');
      expect(opened?.folder, isTrue);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Accessibility ─────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('default semantics label is "File grid"', (tester) async {
      await tester.pumpObers(_gridView());
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'File grid',
        ),
        findsOneWidget,
      );
    });

    testWidgets('custom semantics label is applied', (tester) async {
      await tester.pumpObers(_gridView(semanticsLabel: 'Project files grid'));
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Project files grid',
        ),
        findsOneWidget,
      );
    });

    testWidgets('file cards have semantic labels with type info', (
      tester,
    ) async {
      await tester.pumpObers(_gridView());
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

    testWidgets('folder cards have semantic label with "folder" type', (
      tester,
    ) async {
      await tester.pumpObers(_gridView());
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.label?.contains('Documents') ?? false) &&
              (w.properties.label?.contains('folder') ?? false),
        ),
        findsOneWidget,
      );
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Search highlight ──────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('renders with search query without errors', (tester) async {
      await tester.pumpObers(_gridView(searchQuery: 'doc'));
      // When search query matches, RichText with TextSpan is used for
      // highlighting instead of plain Text. Verify the widget renders.
      expect(find.byType(OiFileGridView), findsOneWidget);
    });

    testWidgets('empty search query shows plain text', (tester) async {
      await tester.pumpObers(_gridView(searchQuery: ''));
      expect(find.text('document.pdf'), findsOneWidget);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Multi-select disabled ─────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('single select mode selects only one', (tester) async {
      Set<Object>? selected;
      await tester.pumpObers(
        _gridView(
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
    // ── Card dimensions ───────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('renders with custom card dimensions', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 800,
          height: 600,
          child: OiFileGridView(
            files: _testFiles,
            selectedKeys: const {},
            onSelectionChange: (_) {},
            onOpen: (_) {},
            cardWidth: 200,
            cardHeight: 220,
            gap: 16,
          ),
        ),
      );
      expect(find.text('document.pdf'), findsOneWidget);
    });
  });
}
