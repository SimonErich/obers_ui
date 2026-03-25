import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_example/apps/component_library/shared/component_showcase_section.dart';

/// Showcase screen for file-related widgets.
class FilesScreen extends StatelessWidget {
  const FilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── OiFileIcon ──────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'File Icon',
            widgetName: 'OiFileIcon',
            description:
                'A file-type icon with a page outline, dog-ear fold, and '
                'colored extension band. The band color is determined '
                'automatically from the file extension.',
            examples: [
              ComponentExample(
                title: 'Various File Types',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OiFileIcon(fileName: 'report.pdf'),
                    OiFileIcon(fileName: 'document.docx'),
                    OiFileIcon(fileName: 'photo.jpg'),
                    OiFileIcon(fileName: 'video.mp4'),
                    OiFileIcon(fileName: 'archive.zip'),
                    OiFileIcon(fileName: 'main.dart'),
                  ],
                ),
              ),
              ComponentExample(
                title: 'Sizes',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    OiFileIcon(fileName: 'file.pdf', size: OiFileIconSize.xs),
                    OiFileIcon(fileName: 'file.pdf', size: OiFileIconSize.sm),
                    OiFileIcon(fileName: 'file.pdf'),
                    OiFileIcon(fileName: 'file.pdf', size: OiFileIconSize.lg),
                    OiFileIcon(fileName: 'file.pdf', size: OiFileIconSize.xl),
                  ],
                ),
              ),
            ],
          ),

          // ── OiFolderIcon ────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Folder Icon',
            widgetName: 'OiFolderIcon',
            description:
                'A folder icon with open/closed states, color customization, '
                'and special variants (shared, starred, locked, trash).',
            examples: [
              ComponentExample(
                title: 'States',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OiFolderIcon(semanticsLabel: 'Closed folder'),
                    OiFolderIcon(
                      state: OiFolderIconState.open,
                      semanticsLabel: 'Open folder',
                    ),
                    OiFolderIcon(
                      state: OiFolderIconState.empty,
                      semanticsLabel: 'Empty folder',
                    ),
                  ],
                ),
              ),
              ComponentExample(
                title: 'Variants',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OiFolderIcon(
                      variant: OiFolderIconVariant.shared,
                      semanticsLabel: 'Shared folder',
                    ),
                    OiFolderIcon(
                      variant: OiFolderIconVariant.starred,
                      semanticsLabel: 'Starred folder',
                    ),
                    OiFolderIcon(
                      variant: OiFolderIconVariant.locked,
                      semanticsLabel: 'Locked folder',
                    ),
                    OiFolderIcon(
                      variant: OiFolderIconVariant.trash,
                      semanticsLabel: 'Trash folder',
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── OiFileTile ──────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'File Tile',
            widgetName: 'OiFileTile',
            description:
                'A single row in a file list view showing icon, name, size, '
                'and modified date. Supports selection and search highlighting.',
            examples: [
              ComponentExample(
                title: 'File Tiles',
                child: Column(
                  children: [
                    OiFileTile(
                      file: OiFileNode(
                        key: '1',
                        name: 'report.pdf',
                        folder: false,
                        size: 2457600,
                        modified: DateTime.now(),
                      ),
                      onTap: () {},
                      semanticsLabel: 'Report PDF file',
                    ),
                    OiFileTile(
                      file: OiFileNode(
                        key: '2',
                        name: 'presentation.pptx',
                        folder: false,
                        size: 5242880,
                        modified: DateTime.now().subtract(
                          const Duration(days: 2),
                        ),
                      ),
                      onTap: () {},
                      semanticsLabel: 'Presentation file',
                    ),
                    OiFileTile(
                      file: OiFileNode(
                        key: '3',
                        name: 'Documents',
                        folder: true,
                        modified: DateTime.now().subtract(
                          const Duration(days: 7),
                        ),
                      ),
                      onTap: () {},
                      semanticsLabel: 'Documents folder',
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── OiFileGridCard ──────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'File Grid Card',
            widgetName: 'OiFileGridCard',
            description:
                'A single card in the grid view of a file explorer. Displays '
                'a file/folder icon and name with selection support.',
            examples: [
              ComponentExample(
                title: 'Grid Cards',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: 120,
                      child: OiFileGridCard(
                        file: const OiFileNode(
                          key: '1',
                          name: 'photo.jpg',
                          folder: false,
                          size: 1228800,
                        ),
                        onTap: () {},
                        semanticsLabel: 'Photo file card',
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: OiFileGridCard(
                        file: const OiFileNode(
                          key: '2',
                          name: 'budget.xlsx',
                          folder: false,
                          size: 524288,
                        ),
                        onTap: () {},
                        semanticsLabel: 'Budget file card',
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      child: OiFileGridCard(
                        file: const OiFileNode(
                          key: '3',
                          name: 'Projects',
                          folder: true,
                        ),
                        onTap: () {},
                        semanticsLabel: 'Projects folder card',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── OiPathBar ───────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Path Bar',
            widgetName: 'OiPathBar',
            description:
                'A dual-mode path navigation bar. In breadcrumb mode, shows '
                'clickable path segments. In edit mode, allows typing a path '
                'directly.',
            examples: [
              ComponentExample(
                title: 'Breadcrumb Navigation',
                child: OiPathBar(
                  segments: const [
                    OiPathSegment(id: 'home', label: 'Home'),
                    OiPathSegment(id: 'docs', label: 'Documents'),
                    OiPathSegment(id: 'reports', label: 'Reports'),
                  ],
                  onNavigate: (_) {},
                ),
              ),
            ],
          ),

          // ── OiFileDropTarget ────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'File Drop Target',
            widgetName: 'OiFileDropTarget',
            description:
                'A drag-and-drop file upload zone that accepts dropped files. '
                'Shows visual feedback when files are dragged over it. '
                'Key parameters: onFilesDropped, allowedExtensions, '
                'maxFileSize, child. \n\nOiFileDropTarget wraps a child widget and provides visual '
                'feedback when files are dragged over the zone. It accepts '
                'file drops and invokes onFilesDropped with the dropped '
                'file data. Supports filtering by extension and file size.',
            examples: [
              ComponentExample(
                title: 'Drop Zone',
                child: OiFileDropTarget(
                  onInternalDrop: (_, __) {},
                  onExternalDrop: (_) {},
                  dropMessage: 'Drop files here to upload',
                  child: Container(
                    height: 120,
                    alignment: Alignment.center,
                    child: const OiLabel.body('Drag files here'),
                  ),
                ),
              ),
            ],
          ),

          // ── OiFileToolbar ───────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'File Toolbar',
            widgetName: 'OiFileToolbar',
            description:
                'A toolbar with breadcrumb navigation, search, and bulk '
                'actions for file management. \n\n'
                'OiFileToolbar renders contextual action buttons based on '
                'the current file selection. Common actions include upload, '
                'new folder, copy, move, delete, and rename. The toolbar '
                'collapses into an overflow menu on narrow screens.',
            examples: [
              ComponentExample(
                title: 'With Breadcrumbs & Selection',
                child: OiFileToolbar(
                  label: 'File toolbar',
                  breadcrumbs: [
                    OiBreadcrumbItem(label: 'Home', onTap: () {}),
                    OiBreadcrumbItem(label: 'Documents', onTap: () {}),
                    const OiBreadcrumbItem(label: 'Reports'),
                  ],
                  selectedCount: 3,
                  onSearch: (_) {},
                ),
              ),
            ],
          ),

          // ── OiFolderTreeItem ────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Folder Tree Item',
            widgetName: 'OiFolderTreeItem',
            description:
                'A tree node widget for rendering folder hierarchies with '
                'expand/collapse and selection support. \n\n'
                'OiFolderTreeItem displays a single folder in a tree '
                'structure. It supports expand/collapse toggling, indent '
                'levels, selection highlighting, and acts as both a drag '
                'source and drop target for file operations.',
            examples: [
              ComponentExample(
                title: 'Folder Items',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OiFolderTreeItem(
                      folder: const OiFileNodeData(
                        id: 'docs',
                        name: 'Documents',
                        isFolder: true,
                        itemCount: 24,
                      ),
                      expanded: true,
                      selected: true,
                      onTap: () {},
                      onExpand: () {},
                    ),
                    OiFolderTreeItem(
                      folder: const OiFileNodeData(
                        id: 'photos',
                        name: 'Photos',
                        isFolder: true,
                        itemCount: 156,
                      ),
                      expanded: false,
                      selected: false,
                      onTap: () {},
                      onExpand: () {},
                    ),
                    OiFolderTreeItem(
                      folder: const OiFileNodeData(
                        id: 'shared',
                        name: 'Shared with me',
                        isFolder: true,
                        isShared: true,
                      ),
                      expanded: false,
                      selected: false,
                      onTap: () {},
                      onExpand: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── OiFileGridView ──────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'File Grid View',
            widgetName: 'OiFileGridView',
            description:
                'A responsive grid layout of file cards with multi-select '
                'and drag-and-drop support. \n\n'
                'OiFileGridView arranges file cards in a responsive grid. '
                'Key parameters: files (List<OiFileNode>), onTap, '
                'onDoubleTap, selectedKeys, onSelectionChange, '
                'searchQuery. Best experienced in the Files mini-app.',
            examples: [
              ComponentExample(
                title: 'Grid of Files',
                child: SizedBox(
                  height: 250,
                  child: OiFileGridView(
                    files: [
                      OiFileNodeData(
                        id: 'g1',
                        name: 'photo.jpg',
                        isFolder: false,
                        size: 1228800,
                        modified: DateTime(2026, 3, 20),
                      ),
                      OiFileNodeData(
                        id: 'g2',
                        name: 'budget.xlsx',
                        isFolder: false,
                        size: 524288,
                        modified: DateTime(2026, 3, 18),
                      ),
                      const OiFileNodeData(
                        id: 'g3',
                        name: 'Projects',
                        isFolder: true,
                        itemCount: 12,
                      ),
                      OiFileNodeData(
                        id: 'g4',
                        name: 'notes.md',
                        isFolder: false,
                        size: 4096,
                        modified: DateTime(2026, 3, 22),
                      ),
                    ],
                    selectedKeys: const {'g2'},
                    onSelectionChange: (_) {},
                    onOpen: (_) {},
                  ),
                ),
              ),
            ],
          ),

          // ── OiFileListView ──────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'File List View',
            widgetName: 'OiFileListView',
            description:
                'A sortable list layout with column headers for name, size, '
                'and modified date. \n\n'
                'OiFileListView displays files in a list with sortable '
                'column headers. Key parameters: files, onTap, '
                'onDoubleTap, sortField, sortDirection, onSortChange, '
                'selectedKeys. Best experienced in the Files mini-app.',
            examples: [
              ComponentExample(
                title: 'List of Files',
                child: SizedBox(
                  height: 250,
                  child: OiFileListView(
                    files: [
                      const OiFileNodeData(
                        id: 'l0',
                        name: 'Documents',
                        isFolder: true,
                        itemCount: 24,
                      ),
                      OiFileNodeData(
                        id: 'l1',
                        name: 'report.pdf',
                        isFolder: false,
                        size: 2457600,
                        modified: DateTime(2026, 3, 23),
                      ),
                      OiFileNodeData(
                        id: 'l2',
                        name: 'presentation.pptx',
                        isFolder: false,
                        size: 5242880,
                        modified: DateTime(2026, 3, 21),
                      ),
                      OiFileNodeData(
                        id: 'l3',
                        name: 'main.dart',
                        isFolder: false,
                        size: 8192,
                        modified: DateTime(2026, 3, 22),
                      ),
                    ],
                    selectedKeys: const {},
                    onSelectionChange: (_) {},
                    onOpen: (_) {},
                  ),
                ),
              ),
            ],
          ),

          // ── OiFileSidebar ───────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'File Sidebar',
            widgetName: 'OiFileSidebar',
            description:
                'A sidebar panel with folder tree navigation, quick-access '
                'sections, and storage usage indicator. \n\n'
                'OiFileSidebar provides folder tree navigation alongside '
                'quick-access sections like Favorites, Recent, and Tags. '
                'It also shows a storage usage indicator at the bottom. '
                'Best experienced in the Files mini-app.',
            examples: [
              ComponentExample(
                title: 'Folder Navigation',
                child: SizedBox(
                  height: 400,
                  child: OiFileSidebar(
                    folderTree: [
                      OiTreeNode<OiFileNodeData>(
                        id: 'home',
                        label: 'Home',
                        data: const OiFileNodeData(
                          id: 'home',
                          name: 'Home',
                          isFolder: true,
                        ),
                        children: [
                          OiTreeNode<OiFileNodeData>(
                            id: 'docs',
                            label: 'Documents',
                            data: const OiFileNodeData(
                              id: 'docs',
                              name: 'Documents',
                              isFolder: true,
                              itemCount: 24,
                            ),
                          ),
                          OiTreeNode<OiFileNodeData>(
                            id: 'photos',
                            label: 'Photos',
                            data: const OiFileNodeData(
                              id: 'photos',
                              name: 'Photos',
                              isFolder: true,
                              itemCount: 156,
                            ),
                          ),
                        ],
                      ),
                    ],
                    selectedFolderId: 'docs',
                    onFolderSelect: (_) {},
                    quickAccess: const [
                      OiQuickAccessItem(
                        id: 'recent',
                        label: 'Recent',
                        icon: OiIcons.clock,
                      ),
                      OiQuickAccessItem(
                        id: 'favorites',
                        label: 'Favorites',
                        icon: OiIcons.star,
                        badgeCount: 5,
                      ),
                    ],
                    storage: const OiStorageData(
                      usedBytes: 5368709120,
                      totalBytes: 10737418240,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── OiFilePreview ───────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'File Preview',
            widgetName: 'OiFilePreview',
            description:
                'A preview panel that displays file content and metadata. \n\n'
                'OiFilePreview renders a preview of the selected file '
                'alongside its metadata (name, size, type, dates). '
                'Supports image thumbnails, PDF previews, and text '
                'content. Best experienced in the Files mini-app.',
            examples: [
              ComponentExample(
                title: 'File Previews',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 160,
                      child: OiFilePreview(
                        file: OiFileNodeData(
                          id: 'p1',
                          name: 'photo.jpg',
                          isFolder: false,
                          size: 1228800,
                          mimeType: 'image/jpeg',
                          modified: DateTime(2026, 3, 20),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      height: 160,
                      child: OiFilePreview(
                        file: OiFileNodeData(
                          id: 'p2',
                          name: 'report.pdf',
                          isFolder: false,
                          size: 2457600,
                          mimeType: 'application/pdf',
                          modified: DateTime(2026, 3, 23),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      height: 160,
                      child: OiFilePreview(
                        file: OiFileNodeData(
                          id: 'p3',
                          name: 'video.mp4',
                          isFolder: false,
                          size: 52428800,
                          mimeType: 'video/mp4',
                          modified: DateTime(2026, 3, 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── OiDropHighlight ─────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Drop Highlight',
            widgetName: 'OiDropHighlight',
            description:
                'A visual indicator overlay for drag-and-drop targets. '
                'Shows a highlighted border and tinted background. \n\n'
                'OiDropHighlight provides visual feedback during '
                'drag-and-drop operations. It highlights the target '
                'area with a border and tinted background to indicate '
                'a valid drop zone. Used internally by file explorer '
                'composites.',
            examples: [
              ComponentExample(
                title: 'Active Drop Zone',
                child: SizedBox(
                  height: 120,
                  child: OiDropHighlight(
                    active: true,
                    message: 'Drop files here',
                    icon: OiIcons.upload,
                  ),
                ),
              ),
              ComponentExample(
                title: 'Border Style',
                child: SizedBox(
                  height: 120,
                  child: OiDropHighlight(
                    active: true,
                    style: OiDropHighlightStyle.border,
                    child: Center(child: OiLabel.body('Content area')),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
