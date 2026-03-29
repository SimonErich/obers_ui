// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/data/oi_tree.dart';
import 'package:obers_ui/src/composites/files/oi_file_list_view.dart';
import 'package:obers_ui/src/composites/files/oi_file_sidebar.dart';
import 'package:obers_ui/src/models/oi_file_explorer_controller.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';
import 'package:obers_ui/src/models/settings/oi_file_explorer_settings.dart';
import 'package:obers_ui/src/modules/oi_file_explorer.dart';

import '../../helpers/pump_app.dart';

// ── Test data ─────────────────────────────────────────────────────────────────

const _testFiles = [
  OiFileNodeData(
    id: 'file1',
    name: 'report.pdf',
    folder: false,
    size: 1024 * 1024,
    mimeType: 'application/pdf',
  ),
  OiFileNodeData(
    id: 'file2',
    name: 'photo.jpg',
    folder: false,
    size: 2048000,
    mimeType: 'image/jpeg',
  ),
  OiFileNodeData(id: 'folder1', name: 'Archive', folder: true, itemCount: 8),
];

final _folderTree = <OiTreeNode<OiFileNodeData>>[
  const OiTreeNode<OiFileNodeData>(
    id: 'root',
    label: 'Home',
    data: OiFileNodeData(id: 'root', name: 'Home', folder: true),
    children: [
      OiTreeNode<OiFileNodeData>(
        id: 'docs',
        label: 'Documents',
        data: OiFileNodeData(id: 'docs', name: 'Documents', folder: true),
      ),
    ],
  ),
];

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Surface size used for all explorer tests to avoid overflow.
const _surfaceSize = Size(1400, 900);

Widget _explorer({
  OiFileExplorerController? controller,
  String label = 'Test file explorer',
  Future<List<OiFileNodeData>> Function(String)? loadFolder,
  Future<List<OiTreeNode<OiFileNodeData>>> Function(String)? loadFolderTree,
  Future<OiFileNodeData> Function(String, String)? onCreateFolder,
  Future<void> Function(OiFileNodeData, String)? onRename,
  Future<void> Function(List<OiFileNodeData>)? onDelete,
  Future<void> Function(List<OiFileNodeData>, OiFileNodeData)? onMove,
  Future<void> Function(List<dynamic>, String)? onUpload,
  OiFileViewMode defaultViewMode = OiFileViewMode.list,
  bool showSidebar = true,
  bool enableUpload = true,
  bool enableDelete = true,
  bool enableRename = true,
  bool enableSearch = true,
  bool enableDragDrop = false,
  bool enableMultiSelect = true,
  bool enableKeyboardShortcuts = false,
  List<OiQuickAccessItem>? quickAccess,
  OiStorageData? storage,
}) {
  return SizedBox(
    width: 1400,
    height: 900,
    child: OiFileExplorer(
      controller: controller ?? OiFileExplorerController(),
      label: label,
      loadFolder: loadFolder ?? (_) async => _testFiles,
      loadFolderTree: loadFolderTree ?? (_) async => _folderTree,
      onCreateFolder:
          onCreateFolder ??
          (parentId, name) async =>
              OiFileNodeData(id: 'new_folder', name: name, folder: true),
      onRename: onRename ?? (_, _) async {},
      onDelete: onDelete ?? (_) async {},
      onMove: onMove ?? (_, _) async {},
      onUpload: onUpload ?? (_, _) async {},
      defaultViewMode: defaultViewMode,
      showSidebar: showSidebar,
      enableUpload: enableUpload,
      enableDelete: enableDelete,
      enableRename: enableRename,
      enableSearch: enableSearch,
      enableDragDrop: enableDragDrop,
      enableMultiSelect: enableMultiSelect,
      enableKeyboardShortcuts: enableKeyboardShortcuts,
      quickAccess: quickAccess,
      storage: storage,
    ),
  );
}

/// Pumps the explorer with a large surface to avoid overflow.
Future<void> _pumpExplorer(WidgetTester tester, Widget widget) async {
  await tester.pumpObers(widget, surfaceSize: _surfaceSize);
}

void main() {
  group('OiFileExplorer', () {
    // ══════════════════════════════════════════════════════════════════════════
    // ── Rendering tests ────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('renders without errors', (tester) async {
      await _pumpExplorer(tester, _explorer());
      await tester.pumpAndSettle();
      expect(find.byType(OiFileExplorer), findsOneWidget);
    });

    testWidgets('renders at small size without crashes', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 800,
          height: 600,
          child: _explorer(
            storage: const OiStorageData(
              usedBytes: 2576980378,
              totalBytes: 10737418240,
            ),
          ),
        ),
        surfaceSize: const Size(800, 600),
      );
      await tester.pumpAndSettle();
      expect(find.byType(OiFileExplorer), findsOneWidget);
    });

    testWidgets('renders with drag-drop no sidebar', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 1400,
          height: 900,
          child: _explorer(
            enableDragDrop: true,
            showSidebar: false,
          ),
        ),
        surfaceSize: const Size(1400, 900),
      );
      await tester.pumpAndSettle();
      expect(find.byType(OiFileExplorer), findsOneWidget);
    });

    testWidgets('renders toolbar', (tester) async {
      await _pumpExplorer(tester, _explorer());
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics && w.properties.label == 'File explorer toolbar',
        ),
        findsOneWidget,
      );
    });

    testWidgets('navigates to root folder on init', (tester) async {
      await _pumpExplorer(tester, _explorer());
      await tester.pumpAndSettle();
      // After init, the explorer auto-navigates to root and loads files.
      expect(find.text('report.pdf'), findsOneWidget);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Sidebar visibility ────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('renders sidebar when showSidebar is true', (tester) async {
      await _pumpExplorer(tester, _explorer());
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics && w.properties.label == 'File explorer sidebar',
        ),
        findsOneWidget,
      );
    });

    testWidgets('hides sidebar when showSidebar is false', (tester) async {
      await _pumpExplorer(tester, _explorer(showSidebar: false));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics && w.properties.label == 'File explorer sidebar',
        ),
        findsNothing,
      );
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Navigation / folder loading ───────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('navigating to a folder loads files', (tester) async {
      final controller = OiFileExplorerController();
      addTearDown(controller.dispose);

      await _pumpExplorer(
        tester,
        _explorer(controller: controller, loadFolder: (_) async => _testFiles),
      );
      await tester.pumpAndSettle();

      // Navigate to root folder
      await controller.navigateTo(
        'root',
        folder: const OiFileNodeData(id: 'root', name: 'Home', folder: true),
      );
      await tester.pumpAndSettle();

      expect(find.text('report.pdf'), findsOneWidget);
      expect(find.text('photo.jpg'), findsOneWidget);
      expect(find.text('Archive'), findsOneWidget);
    });

    testWidgets('displays files in list view by default', (tester) async {
      final controller = OiFileExplorerController();
      addTearDown(controller.dispose);

      await _pumpExplorer(tester, _explorer(controller: controller));
      await tester.pumpAndSettle();

      await controller.navigateTo(
        'root',
        folder: const OiFileNodeData(id: 'root', name: 'Home', folder: true),
      );
      await tester.pumpAndSettle();

      // In list view, column headers should be visible
      expect(find.textContaining('Name'), findsOneWidget);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── View mode toggle ──────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('view mode can be toggled via controller', (tester) async {
      final controller = OiFileExplorerController();
      addTearDown(controller.dispose);

      await _pumpExplorer(tester, _explorer(controller: controller));
      await tester.pumpAndSettle();

      await controller.navigateTo(
        'root',
        folder: const OiFileNodeData(id: 'root', name: 'Home', folder: true),
      );
      await tester.pumpAndSettle();

      // Default is list view
      expect(controller.viewMode, OiFileViewMode.list);

      // Toggle to grid view
      controller.setViewMode(OiFileViewMode.grid);
      await tester.pumpAndSettle();

      expect(controller.viewMode, OiFileViewMode.grid);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Selection ─────────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('controller selection changes are reflected in UI', (
      tester,
    ) async {
      final controller = OiFileExplorerController();
      addTearDown(controller.dispose);

      await _pumpExplorer(tester, _explorer(controller: controller));
      await tester.pumpAndSettle();

      await controller.navigateTo(
        'root',
        folder: const OiFileNodeData(id: 'root', name: 'Home', folder: true),
      );
      await tester.pumpAndSettle();

      // Select a file
      controller.select('file1');
      await tester.pump();

      expect(controller.selectedKeys, {'file1'});
    });

    testWidgets('selection toolbar appears when items are selected', (
      tester,
    ) async {
      final controller = OiFileExplorerController();
      addTearDown(controller.dispose);

      await _pumpExplorer(tester, _explorer(controller: controller));
      await tester.pumpAndSettle();

      await controller.navigateTo(
        'root',
        folder: const OiFileNodeData(id: 'root', name: 'Home', folder: true),
      );
      await tester.pumpAndSettle();

      controller.select('file1');
      await tester.pump();

      expect(find.text('1 selected'), findsOneWidget);
    });

    testWidgets('Clear button clears selection', (tester) async {
      final controller = OiFileExplorerController();
      addTearDown(controller.dispose);

      await _pumpExplorer(tester, _explorer(controller: controller));
      await tester.pumpAndSettle();

      await controller.navigateTo(
        'root',
        folder: const OiFileNodeData(id: 'root', name: 'Home', folder: true),
      );
      await tester.pumpAndSettle();

      controller.select('file1');
      await tester.pump();
      expect(find.text('1 selected'), findsOneWidget);

      await tester.tap(find.text('Clear'));
      await tester.pump();

      expect(controller.selectedKeys, isEmpty);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Upload button ─────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('upload button is shown when enableUpload is true', (
      tester,
    ) async {
      await _pumpExplorer(tester, _explorer());
      await tester.pumpAndSettle();
      // May appear both in toolbar and in empty state action
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Upload files',
        ),
        findsWidgets,
      );
    });

    testWidgets('upload button is hidden when enableUpload is false', (
      tester,
    ) async {
      await _pumpExplorer(tester, _explorer(enableUpload: false));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Upload files',
        ),
        findsNothing,
      );
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── New folder button ─────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('new folder button is rendered in toolbar', (tester) async {
      await _pumpExplorer(tester, _explorer());
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'New folder',
        ),
        findsWidgets,
      );
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Navigation ────────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('breadcrumb path bar is rendered', (tester) async {
      await _pumpExplorer(tester, _explorer());
      await tester.pumpAndSettle();
      // The path bar renders the root "Home" segment.
      expect(find.text('Home'), findsWidgets);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Search ────────────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('search button is shown when enableSearch is true', (
      tester,
    ) async {
      await _pumpExplorer(tester, _explorer());
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Search',
        ),
        findsOneWidget,
      );
    });

    testWidgets('search button is hidden when enableSearch is false', (
      tester,
    ) async {
      await _pumpExplorer(tester, _explorer(enableSearch: false));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Search',
        ),
        findsNothing,
      );
    });

    testWidgets('search with no results shows empty state', (tester) async {
      final controller = OiFileExplorerController();
      addTearDown(controller.dispose);

      await _pumpExplorer(tester, _explorer(controller: controller));
      await tester.pumpAndSettle();

      await controller.navigateTo(
        'root',
        folder: const OiFileNodeData(id: 'root', name: 'Home', folder: true),
      );
      await tester.pumpAndSettle();

      // Set a search query that matches nothing
      controller.setSearchQuery('zzz_no_match_zzz');
      await tester.pump();

      expect(find.textContaining('No files match'), findsOneWidget);
    });

    testWidgets('search filters files by name', (tester) async {
      final controller = OiFileExplorerController();
      addTearDown(controller.dispose);

      await _pumpExplorer(tester, _explorer(controller: controller));
      await tester.pumpAndSettle();

      await controller.navigateTo(
        'root',
        folder: const OiFileNodeData(id: 'root', name: 'Home', folder: true),
      );
      await tester.pumpAndSettle();

      // Search for 'report' - filters to only matching files
      controller.setSearchQuery('report');
      await tester.pump();

      // 'photo.jpg' and 'Archive' should not appear since they don't match
      expect(find.text('photo.jpg'), findsNothing);
      expect(find.text('Archive'), findsNothing);
      // The matching file is rendered (possibly via RichText for highlighting)
      expect(find.byType(OiFileListView), findsOneWidget);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Empty folder with upload action ───────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('empty folder shows upload action when enabled', (
      tester,
    ) async {
      await _pumpExplorer(tester, _explorer(loadFolder: (_) async => []));
      await tester.pumpAndSettle();

      expect(find.text('This folder is empty'), findsOneWidget);
      expect(find.text('Upload files'), findsWidgets);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Controller lifecycle ──────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('controller listener is removed on dispose', (tester) async {
      final controller = OiFileExplorerController();

      await _pumpExplorer(tester, _explorer(controller: controller));
      await tester.pumpAndSettle();

      // Rebuild with a different widget to dispose the explorer
      await tester.pumpObers(const SizedBox(width: 100, height: 100));
      await tester.pumpAndSettle();

      // Controller operations should not throw after explorer is disposed
      controller
        ..setViewMode(OiFileViewMode.grid)
        ..dispose();
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Selection toolbar actions ─────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('selection toolbar shows Move and Delete buttons', (
      tester,
    ) async {
      final controller = OiFileExplorerController();
      addTearDown(controller.dispose);

      await _pumpExplorer(tester, _explorer(controller: controller));
      await tester.pumpAndSettle();

      await controller.navigateTo(
        'root',
        folder: const OiFileNodeData(id: 'root', name: 'Home', folder: true),
      );
      await tester.pumpAndSettle();

      controller.select('file1');
      await tester.pump();

      expect(find.text('Move'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── View mode button group ────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('view mode button group is rendered', (tester) async {
      await _pumpExplorer(tester, _explorer());
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'View mode',
        ),
        findsOneWidget,
      );
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Accessibility ─────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('explorer has container semantics with label', (tester) async {
      await _pumpExplorer(tester, _explorer(label: 'My Files'));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              w.properties.label == 'My Files' &&
              w.container,
        ),
        findsOneWidget,
      );
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Folder tree error handling ────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('renders even when folder tree loading fails', (tester) async {
      await _pumpExplorer(
        tester,
        _explorer(
          loadFolderTree: (_) async => throw Exception('Network error'),
        ),
      );
      await tester.pumpAndSettle();
      // Should still render the toolbar and content area
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics && w.properties.label == 'File explorer toolbar',
        ),
        findsOneWidget,
      );
    });
  });
}
