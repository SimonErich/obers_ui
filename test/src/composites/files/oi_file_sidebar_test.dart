// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/data/oi_tree.dart';
import 'package:obers_ui/src/composites/files/oi_file_sidebar.dart';
import 'package:obers_ui/src/models/oi_file_node_data.dart';

import '../../../helpers/pump_app.dart';

// ── Test data ─────────────────────────────────────────────────────────────────

final _folderTree = <OiTreeNode<OiFileNodeData>>[
  OiTreeNode<OiFileNodeData>(
    id: 'root',
    label: 'Root',
    data: const OiFileNodeData(id: 'root', name: 'Root', isFolder: true),
    children: [
      OiTreeNode<OiFileNodeData>(
        id: 'docs',
        label: 'Documents',
        data: const OiFileNodeData(
          id: 'docs',
          name: 'Documents',
          isFolder: true,
          itemCount: 10,
        ),
      ),
      OiTreeNode<OiFileNodeData>(
        id: 'photos',
        label: 'Photos',
        data: const OiFileNodeData(
          id: 'photos',
          name: 'Photos',
          isFolder: true,
          itemCount: 42,
        ),
      ),
    ],
  ),
];

final _quickAccess = [
  const OiQuickAccessItem(
    id: 'home',
    label: 'Home',
    icon: IconData(0xe88a, fontFamily: 'MaterialIcons'),
  ),
  const OiQuickAccessItem(
    id: 'downloads',
    label: 'Downloads',
    icon: IconData(0xf090, fontFamily: 'MaterialIcons'),
    badgeCount: 3,
  ),
  const OiQuickAccessItem(
    id: 'trash',
    label: 'Trash',
    icon: IconData(0xe872, fontFamily: 'MaterialIcons'),
  ),
];

final _favorites = [
  const OiFileNodeData(
    id: 'fav1',
    name: 'Important Docs',
    isFolder: true,
    isFavorite: true,
  ),
  const OiFileNodeData(
    id: 'fav2',
    name: 'Work Projects',
    isFolder: true,
    isFavorite: true,
  ),
];

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _sidebar({
  List<OiTreeNode<OiFileNodeData>>? folderTree,
  String? selectedFolderId,
  ValueChanged<OiFileNodeData>? onFolderSelect,
  List<OiQuickAccessItem>? quickAccess,
  ValueChanged<OiQuickAccessItem>? onQuickAccessTap,
  List<OiFileNodeData>? favorites,
  ValueChanged<OiFileNodeData>? onFavoriteTap,
  ValueChanged<OiFileNodeData>? onNewFolder,
  ValueChanged<OiFileNodeData>? onRenameFolder,
  ValueChanged<OiFileNodeData>? onDeleteFolder,
  OiStorageData? storage,
  double width = 260,
  String? semanticsLabel,
}) {
  return SizedBox(
    width: width + 100,
    height: 800,
    child: OiFileSidebar(
      folderTree: folderTree ?? _folderTree,
      selectedFolderId: selectedFolderId,
      onFolderSelect: onFolderSelect ?? (_) {},
      quickAccess: quickAccess,
      onQuickAccessTap: onQuickAccessTap,
      favorites: favorites,
      onFavoriteTap: onFavoriteTap,
      onNewFolder: onNewFolder,
      onRenameFolder: onRenameFolder,
      onDeleteFolder: onDeleteFolder,
      storage: storage,
      width: width,
      semanticsLabel: semanticsLabel,
    ),
  );
}

void main() {
  group('OiFileSidebar', () {
    // ══════════════════════════════════════════════════════════════════════════
    // ── Rendering tests ────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('renders without errors', (tester) async {
      await tester.pumpObers(_sidebar());
      expect(find.text('Folders'), findsOneWidget);
    });

    testWidgets('renders folder tree section header', (tester) async {
      await tester.pumpObers(_sidebar());
      expect(find.text('Folders'), findsOneWidget);
    });

    testWidgets('renders folder tree nodes', (tester) async {
      await tester.pumpObers(_sidebar());
      expect(find.text('Root'), findsOneWidget);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Quick access section ──────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('renders quick access section when provided', (tester) async {
      await tester.pumpObers(
        _sidebar(quickAccess: _quickAccess),
      );
      expect(find.text('Quick Access'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Downloads'), findsOneWidget);
      expect(find.text('Trash'), findsOneWidget);
    });

    testWidgets('does not render quick access when not provided',
        (tester) async {
      await tester.pumpObers(_sidebar());
      expect(find.text('Quick Access'), findsNothing);
    });

    testWidgets('renders badge count on quick access items', (tester) async {
      await tester.pumpObers(
        _sidebar(quickAccess: _quickAccess),
      );
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('tapping quick access item calls onQuickAccessTap',
        (tester) async {
      OiQuickAccessItem? tapped;
      await tester.pumpObers(
        _sidebar(
          quickAccess: _quickAccess,
          onQuickAccessTap: (item) => tapped = item,
        ),
      );
      await tester.tap(find.text('Home'));
      await tester.pump();
      expect(tapped?.id, 'home');
    });

    testWidgets('tapping Downloads quick access fires callback',
        (tester) async {
      OiQuickAccessItem? tapped;
      await tester.pumpObers(
        _sidebar(
          quickAccess: _quickAccess,
          onQuickAccessTap: (item) => tapped = item,
        ),
      );
      await tester.tap(find.text('Downloads'));
      await tester.pump();
      expect(tapped?.id, 'downloads');
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Favorites section ─────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('renders favorites section when provided', (tester) async {
      await tester.pumpObers(
        _sidebar(favorites: _favorites),
      );
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Important Docs'), findsOneWidget);
      expect(find.text('Work Projects'), findsOneWidget);
    });

    testWidgets('does not render favorites when not provided', (tester) async {
      await tester.pumpObers(_sidebar());
      expect(find.text('Favorites'), findsNothing);
    });

    testWidgets('tapping favorite calls onFavoriteTap', (tester) async {
      OiFileNodeData? tapped;
      await tester.pumpObers(
        _sidebar(
          favorites: _favorites,
          onFavoriteTap: (f) => tapped = f,
        ),
      );
      await tester.tap(find.text('Important Docs'));
      await tester.pump();
      expect(tapped?.id, 'fav1');
    });

    testWidgets('favorites have semantic labels', (tester) async {
      await tester.pumpObers(
        _sidebar(favorites: _favorites),
      );
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.label?.contains('Important Docs') ?? false),
        ),
        findsOneWidget,
      );
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Storage indicator ─────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('renders storage indicator when provided', (tester) async {
      await tester.pumpObers(
        _sidebar(
          storage: const OiStorageData(
            usedBytes: 500 * 1024 * 1024,
            totalBytes: 1024 * 1024 * 1024,
          ),
        ),
      );
      // Storage indicator should be rendered without errors
      expect(find.text('Folders'), findsOneWidget);
    });

    testWidgets('does not render storage when not provided', (tester) async {
      await tester.pumpObers(_sidebar());
      // Just verify sidebar renders without storage
      expect(find.text('Folders'), findsOneWidget);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── New folder button ─────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('renders New Folder button when onNewFolder is provided',
        (tester) async {
      await tester.pumpObers(
        _sidebar(onNewFolder: (_) {}),
      );
      expect(find.text('+ New Folder'), findsOneWidget);
    });

    testWidgets('does not render New Folder button when onNewFolder is null',
        (tester) async {
      await tester.pumpObers(_sidebar());
      expect(find.text('+ New Folder'), findsNothing);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Accessibility ─────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('default semantics label is "File sidebar"', (tester) async {
      await tester.pumpObers(_sidebar());
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'File sidebar',
        ),
        findsOneWidget,
      );
    });

    testWidgets('custom semantics label is applied', (tester) async {
      await tester.pumpObers(
        _sidebar(semanticsLabel: 'Project navigation'),
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Project navigation',
        ),
        findsOneWidget,
      );
    });

    testWidgets('section headers have header semantics', (tester) async {
      await tester.pumpObers(
        _sidebar(quickAccess: _quickAccess, favorites: _favorites),
      );
      // Section headers should have header: true in semantics
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.header == true,
        ),
        findsWidgets,
      );
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Empty tree ────────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('renders with empty folder tree', (tester) async {
      await tester.pumpObers(_sidebar(folderTree: const []));
      // Should still render the Folders section header
      expect(find.text('Folders'), findsOneWidget);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── Width ─────────────────────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('respects custom width', (tester) async {
      await tester.pumpObers(_sidebar(width: 300));
      final sizedBox = tester.widget<SizedBox>(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 300,
        ),
      );
      expect(sizedBox.width, 300);
    });

    // ══════════════════════════════════════════════════════════════════════════
    // ── All sections together ─────────────────────────────────────────────
    // ══════════════════════════════════════════════════════════════════════════

    testWidgets('renders all sections together', (tester) async {
      await tester.pumpObers(
        _sidebar(
          quickAccess: _quickAccess,
          favorites: _favorites,
          onNewFolder: (_) {},
          storage: const OiStorageData(
            usedBytes: 100 * 1024 * 1024,
            totalBytes: 1024 * 1024 * 1024,
          ),
        ),
      );
      expect(find.text('Quick Access'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Folders'), findsOneWidget);
      expect(find.text('+ New Folder'), findsOneWidget);
    });
  });
}
