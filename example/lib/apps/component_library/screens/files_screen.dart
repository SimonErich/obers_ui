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
          const ComponentShowcaseSection(
            title: 'File Drop Target',
            widgetName: 'OiFileDropTarget',
            description:
                'A drag-and-drop file upload zone that accepts dropped files. '
                'Shows visual feedback when files are dragged over it. '
                'Key parameters: onFilesDropped, allowedExtensions, '
                'maxFileSize, child.',
            examples: [
              ComponentExample(
                title: 'Description',
                child: OiLabel.body(
                  'OiFileDropTarget wraps a child widget and provides visual '
                  'feedback when files are dragged over the zone. It accepts '
                  'file drops and invokes onFilesDropped with the dropped '
                  'file data. Supports filtering by extension and file size.',
                ),
              ),
            ],
          ),

          // ── OiFileToolbar ───────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'File Toolbar',
            widgetName: 'OiFileToolbar',
            description:
                'A toolbar for file management actions such as copy, move, '
                'delete, rename, and upload. Adapts to the current selection '
                'state and available actions.',
            examples: [
              ComponentExample(
                title: 'Description',
                child: OiLabel.body(
                  'OiFileToolbar renders contextual action buttons based on '
                  'the current file selection. Common actions include upload, '
                  'new folder, copy, move, delete, and rename. The toolbar '
                  'collapses into an overflow menu on narrow screens.',
                ),
              ),
            ],
          ),

          // ── OiFolderTreeItem ────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Folder Tree Item',
            widgetName: 'OiFolderTreeItem',
            description:
                'A tree node widget for rendering folder hierarchies with '
                'expand/collapse, drag-and-drop, and context menu support.',
            examples: [
              ComponentExample(
                title: 'Description',
                child: OiLabel.body(
                  'OiFolderTreeItem displays a single folder in a tree '
                  'structure. It supports expand/collapse toggling, indent '
                  'levels, selection highlighting, and acts as both a drag '
                  'source and drop target for file operations.',
                ),
              ),
            ],
          ),

          // ── OiFileGridView ──────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'File Grid View',
            widgetName: 'OiFileGridView',
            description:
                'A responsive grid layout of OiFileGridCard widgets. '
                'Supports multi-select, drag-and-drop reordering, and '
                'search highlighting.',
            examples: [
              ComponentExample(
                title: 'Description',
                child: OiLabel.body(
                  'OiFileGridView arranges file cards in a responsive grid. '
                  'Key parameters: files (List<OiFileNode>), onTap, '
                  'onDoubleTap, selectedKeys, onSelectionChange, '
                  'searchQuery. Best experienced in the Files mini-app.',
                ),
              ),
            ],
          ),

          // ── OiFileListView ──────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'File List View',
            widgetName: 'OiFileListView',
            description:
                'A sortable list layout of OiFileTile widgets with column '
                'headers for name, size, and modified date.',
            examples: [
              ComponentExample(
                title: 'Description',
                child: OiLabel.body(
                  'OiFileListView displays files in a list with sortable '
                  'column headers. Key parameters: files, onTap, '
                  'onDoubleTap, sortField, sortDirection, onSortChange, '
                  'selectedKeys. Best experienced in the Files mini-app.',
                ),
              ),
            ],
          ),

          // ── OiFileSidebar ───────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'File Sidebar',
            widgetName: 'OiFileSidebar',
            description:
                'A sidebar panel with folder tree navigation, quick-access '
                'sections (favorites, recent, tags), and storage usage.',
            examples: [
              ComponentExample(
                title: 'Description',
                child: OiLabel.body(
                  'OiFileSidebar provides folder tree navigation alongside '
                  'quick-access sections like Favorites, Recent, and Tags. '
                  'It also shows a storage usage indicator at the bottom. '
                  'Best experienced in the Files mini-app.',
                ),
              ),
            ],
          ),

          // ── OiFilePreview ───────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'File Preview',
            widgetName: 'OiFilePreview',
            description:
                'A preview panel that displays file content (images, PDFs, '
                'text) and metadata in a detail sidebar.',
            examples: [
              ComponentExample(
                title: 'Description',
                child: OiLabel.body(
                  'OiFilePreview renders a preview of the selected file '
                  'alongside its metadata (name, size, type, dates). '
                  'Supports image thumbnails, PDF previews, and text '
                  'content. Best experienced in the Files mini-app.',
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
                'Shows a highlighted border and background when files '
                'are dragged over a valid drop zone.',
            examples: [
              ComponentExample(
                title: 'Description',
                child: OiLabel.body(
                  'OiDropHighlight provides visual feedback during '
                  'drag-and-drop operations. It highlights the target '
                  'area with a border and tinted background to indicate '
                  'a valid drop zone. Used internally by file explorer '
                  'composites.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
