import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_cms.dart';

/// Category management screen with a tree view and detail panel.
class CmsCategoriesScreen extends StatefulWidget {
  const CmsCategoriesScreen({super.key});

  @override
  State<CmsCategoriesScreen> createState() => _CmsCategoriesScreenState();
}

class _CmsCategoriesScreenState extends State<CmsCategoriesScreen> {
  late OiTreeController _treeController;
  late List<OiTreeNode<String>> _nodes;
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _treeController = OiTreeController();
    _nodes = buildCategoryTree();
  }

  @override
  void dispose() {
    _treeController.dispose();
    super.dispose();
  }

  OiTreeNode<String>? _findNode(List<OiTreeNode<String>> nodes, String id) {
    for (final node in nodes) {
      if (node.id == id) return node;
      if (node.children.isNotEmpty) {
        final found = _findNode(node.children, id);
        if (found != null) return found;
      }
    }
    return null;
  }

  int _countDescendants(OiTreeNode<String> node) {
    var count = node.children.length;
    for (final child in node.children) {
      count += _countDescendants(child);
    }
    return count;
  }

  void _showAddDialog() {
    final controller = TextEditingController();
    late OiOverlayHandle handle;
    handle = OiDialog.show(
      context,
      label: 'Add category',
      dialog: OiDialog.standard(
        label: 'Add category',
        title: 'New Category',
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: OiTextInput(
            controller: controller,
            label: 'Category name',
            placeholder: 'Enter category name',
          ),
        ),
        actions: [
          OiButton.ghost(
            label: 'Cancel',
            semanticLabel: 'Cancel',
            onTap: () => handle.dismiss(),
          ),
          OiButton.primary(
            label: 'Add',
            semanticLabel: 'Add category',
            onTap: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final id = 'cat-${name.toLowerCase().replaceAll(' ', '-')}';
                setState(() {
                  if (_selectedId != null) {
                    _nodes = _addChild(_nodes, _selectedId!, id, name);
                    _treeController.expand(_selectedId!);
                  } else {
                    _nodes = [
                      ..._nodes,
                      OiTreeNode<String>(id: id, label: name, data: name),
                    ];
                  }
                });
                OiToast.show(
                  context,
                  message: 'Category "$name" added',
                  level: OiToastLevel.success,
                );
              }
              handle.dismiss();
            },
          ),
        ],
        onClose: () => handle.dismiss(),
      ),
    );
  }

  void _showRenameDialog(OiTreeNode<String> node) {
    final controller = TextEditingController(text: node.label);
    late OiOverlayHandle handle;
    handle = OiDialog.show(
      context,
      label: 'Rename category',
      dialog: OiDialog.standard(
        label: 'Rename category',
        title: 'Rename "${node.label}"',
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: OiTextInput(
            controller: controller,
            label: 'Category name',
            placeholder: 'Enter new name',
          ),
        ),
        actions: [
          OiButton.ghost(
            label: 'Cancel',
            semanticLabel: 'Cancel',
            onTap: () => handle.dismiss(),
          ),
          OiButton.primary(
            label: 'Rename',
            semanticLabel: 'Rename category',
            onTap: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _nodes = _renameNode(_nodes, node.id, name);
                });
                OiToast.show(
                  context,
                  message: 'Renamed to "$name"',
                  level: OiToastLevel.success,
                );
              }
              handle.dismiss();
            },
          ),
        ],
        onClose: () => handle.dismiss(),
      ),
    );
  }

  void _showDeleteDialog(OiTreeNode<String> node) {
    late OiOverlayHandle handle;
    handle = OiDialog.show(
      context,
      label: 'Delete category',
      dialog: OiDialog.confirm(
        label: 'Confirm delete',
        title: 'Delete "${node.label}"?',
        content: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: OiLabel.body(
            'This will permanently remove the category '
            'and all its subcategories.',
          ),
        ),
        onClose: () => handle.dismiss(),
        actions: [
          OiButton.ghost(
            label: 'Cancel',
            semanticLabel: 'Cancel',
            onTap: () => handle.dismiss(),
          ),
          OiButton.primary(
            label: 'Delete',
            semanticLabel: 'Confirm delete',
            onTap: () {
              setState(() {
                _nodes = _removeNode(_nodes, node.id);
                if (_selectedId == node.id) _selectedId = null;
              });
              OiToast.show(
                context,
                message: '"${node.label}" deleted',
                level: OiToastLevel.success,
              );
              handle.dismiss();
            },
          ),
        ],
      ),
    );
  }

  // ── Tree manipulation helpers ─────────────────────────────────────────────

  List<OiTreeNode<String>> _addChild(
    List<OiTreeNode<String>> nodes,
    String parentId,
    String childId,
    String childLabel,
  ) {
    return nodes.map((n) {
      if (n.id == parentId) {
        return OiTreeNode<String>(
          id: n.id,
          label: n.label,
          data: n.data,
          icon: n.icon,
          children: [
            ...n.children,
            OiTreeNode<String>(
              id: childId,
              label: childLabel,
              data: childLabel,
            ),
          ],
        );
      }
      if (n.children.isNotEmpty) {
        return OiTreeNode<String>(
          id: n.id,
          label: n.label,
          data: n.data,
          icon: n.icon,
          children: _addChild(n.children, parentId, childId, childLabel),
        );
      }
      return n;
    }).toList();
  }

  List<OiTreeNode<String>> _renameNode(
    List<OiTreeNode<String>> nodes,
    String id,
    String newLabel,
  ) {
    return nodes.map((n) {
      if (n.id == id) {
        return OiTreeNode<String>(
          id: n.id,
          label: newLabel,
          data: newLabel,
          icon: n.icon,
          children: n.children,
        );
      }
      if (n.children.isNotEmpty) {
        return OiTreeNode<String>(
          id: n.id,
          label: n.label,
          data: n.data,
          icon: n.icon,
          children: _renameNode(n.children, id, newLabel),
        );
      }
      return n;
    }).toList();
  }

  List<OiTreeNode<String>> _removeNode(
    List<OiTreeNode<String>> nodes,
    String id,
  ) {
    final result = <OiTreeNode<String>>[];
    for (final n in nodes) {
      if (n.id == id) continue;
      if (n.children.isNotEmpty) {
        result.add(
          OiTreeNode<String>(
            id: n.id,
            label: n.label,
            data: n.data,
            icon: n.icon,
            children: _removeNode(n.children, id),
          ),
        );
      } else {
        result.add(n);
      }
    }
    return result;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final selectedNode = _selectedId != null
        ? _findNode(_nodes, _selectedId!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(spacing.md),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.borderSubtle)),
          ),
          child: Row(
            children: [
              const Expanded(child: OiLabel.h3('Categories')),
              OiButton.primary(
                label: 'Add Category',
                semanticLabel: 'Add category',
                icon: OiIcons.plus,
                onTap: _showAddDialog,
              ),
            ],
          ),
        ),

        // Body: tree + detail panel
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tree panel
              SizedBox(
                width: 300,
                child: OiTree<String>(
                  label: 'Category tree',
                  nodes: _nodes,
                  controller: _treeController,
                  selectable: true,
                  showLines: true,
                  onNodeTap: (node) {
                    setState(() => _selectedId = node.id);
                  },
                  onSelectionChanged: (ids) {
                    if (ids.isNotEmpty) {
                      setState(() => _selectedId = ids.first);
                    }
                  },
                ),
              ),

              // Divider
              Container(width: 1, color: colors.borderSubtle),

              // Detail panel
              Expanded(
                child: selectedNode != null
                    ? _buildDetailPanel(selectedNode, colors, spacing)
                    : Center(
                        child: OiLabel.body(
                          'Select a category to see details',
                          color: colors.textMuted,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailPanel(
    OiTreeNode<String> node,
    OiColorScheme colors,
    OiSpacingScale spacing,
  ) {
    final descendantCount = _countDescendants(node);

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OiLabel.h3(node.label),
          SizedBox(height: spacing.md),
          OiDetailView(
            label: 'Category details',
            sections: [
              OiDetailSection(
                title: 'Details',
                fields: [
                  OiDetailField(label: 'ID', value: node.id),
                  OiDetailField(
                    label: 'Direct children',
                    value: '${node.children.length}',
                  ),
                  OiDetailField(
                    label: 'Total descendants',
                    value: '$descendantCount',
                  ),
                  OiDetailField(
                    label: 'Type',
                    value: node.hasChildren ? 'Branch' : 'Leaf',
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: spacing.lg),
          Row(
            children: [
              OiButton.secondary(
                label: 'Rename',
                semanticLabel: 'Rename category',
                icon: OiIcons.pencilSquare,
                onTap: () => _showRenameDialog(node),
              ),
              SizedBox(width: spacing.sm),
              OiButton.ghost(
                label: 'Delete',
                semanticLabel: 'Delete category',
                icon: OiIcons.trash,
                onTap: () => _showDeleteDialog(node),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
