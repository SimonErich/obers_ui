import 'package:flutter/widgets.dart';

// ── Node definition ───────────────────────────────────────────────────────────

/// A single node in an [OiTree].
///
/// Nodes are immutable value objects. Build the tree by nesting [OiTreeNode]
/// instances through the [children] list.
///
/// {@category Composites}
@immutable
class OiTreeNode<T> {
  /// Creates an [OiTreeNode].
  const OiTreeNode({
    required this.id,
    required this.label,
    this.data,
    this.children = const [],
    this.leaf = false,
    this.icon,
  });

  /// A unique identifier for this node within the tree.
  final String id;

  /// The human-readable label displayed for this node.
  final String label;

  /// Optional typed data payload attached to this node.
  final T? data;

  /// Direct children of this node.
  final List<OiTreeNode<T>> children;

  /// When `true`, this node is always treated as a leaf even if [children] is
  /// non-empty (e.g. for lazy-loading scenarios).
  final bool leaf;

  /// Optional leading icon widget.
  final Widget? icon;

  /// Whether this node has any children and is not forced to leaf mode.
  bool get hasChildren => !leaf && children.isNotEmpty;
}

// ── Controller ────────────────────────────────────────────────────────────────

/// Controls the interactive state of an [OiTree].
///
/// Manages the set of expanded and selected node IDs. Notifies listeners on
/// every state mutation so that an [OiTree] can rebuild.
///
/// {@category Composites}
class OiTreeController extends ChangeNotifier {
  /// Creates an [OiTreeController].
  ///
  /// [multiSelect] controls whether multiple nodes can be selected at once.
  OiTreeController({this.multiSelect = false});

  /// Whether multiple nodes may be selected simultaneously.
  final bool multiSelect;

  /// The set of IDs of currently expanded nodes.
  final Set<String> expandedIds = {};

  /// The set of IDs of currently selected nodes.
  final Set<String> selectedIds = {};

  // ── Expand / collapse ─────────────────────────────────────────────────────

  /// Expands the node identified by [id].
  ///
  /// Does nothing (and does not notify) when [id] is already expanded.
  void expand(String id) {
    if (expandedIds.contains(id)) return;
    expandedIds.add(id);
    notifyListeners();
  }

  /// Collapses the node identified by [id].
  ///
  /// Does nothing (and does not notify) when [id] is already collapsed.
  void collapse(String id) {
    if (!expandedIds.remove(id)) return;
    notifyListeners();
  }

  /// Toggles the expanded state of the node identified by [id].
  void toggle(String id) {
    if (expandedIds.contains(id)) {
      expandedIds.remove(id);
    } else {
      expandedIds.add(id);
    }
    notifyListeners();
  }

  /// Expands all nodes in [ids].
  void expandAll(Iterable<String> ids) {
    final before = expandedIds.length;
    expandedIds.addAll(ids);
    if (expandedIds.length != before) notifyListeners();
  }

  /// Collapses all currently expanded nodes.
  void collapseAll() {
    if (expandedIds.isEmpty) return;
    expandedIds.clear();
    notifyListeners();
  }

  // ── Selection ─────────────────────────────────────────────────────────────

  /// Selects the node identified by [id].
  ///
  /// When [multiSelect] is `false`, any previous selection is cleared first.
  void select(String id) {
    if (!multiSelect) selectedIds.clear();
    if (selectedIds.contains(id)) return;
    selectedIds.add(id);
    notifyListeners();
  }

  /// Deselects the node identified by [id].
  ///
  /// Does nothing (and does not notify) when [id] is not selected.
  void deselect(String id) {
    if (!selectedIds.remove(id)) return;
    notifyListeners();
  }

  /// Clears the entire selection.
  ///
  /// Does nothing (and does not notify) when already empty.
  void clearSelection() {
    if (selectedIds.isEmpty) return;
    selectedIds.clear();
    notifyListeners();
  }

  /// Whether the node identified by [id] is expanded.
  bool expanded(String id) => expandedIds.contains(id);

  /// Whether the node identified by [id] is selected.
  bool selected(String id) => selectedIds.contains(id);
}

// ── Widget ────────────────────────────────────────────────────────────────────

/// A hierarchical tree-view widget.
///
/// Renders a list of root [OiTreeNode]s, supporting expand/collapse,
/// single or multi-node selection, lazy-loading children, and custom
/// node builders.
///
/// **Accessibility (REQ-0014):** [label] is required so every tree widget has
/// an accessible description announced by screen readers.
///
/// ```dart
/// OiTree<MyData>(
///   label: 'File browser',
///   nodes: [
///     OiTreeNode(id: 'root', label: 'Root', children: [
///       OiTreeNode(id: 'child1', label: 'Child 1'),
///     ]),
///   ],
/// )
/// ```
///
/// {@category Composites}
class OiTree<T> extends StatefulWidget {
  /// Creates an [OiTree].
  const OiTree({
    required this.label,
    required this.nodes,
    this.controller,
    this.onNodeTap,
    this.onNodeDoubleTap,
    this.onExpansionChanged,
    this.onSelectionChanged,
    this.nodeBuilder,
    this.indentWidth = 24,
    this.rowHeight = 40,
    this.selectable = false,
    this.multiSelect = false,
    this.showLines = false,
    super.key,
  });

  /// Accessible label describing the tree for screen readers.
  final String label;

  /// The root nodes of the tree.
  final List<OiTreeNode<T>> nodes;

  /// Optional external controller. When `null`, the widget manages its own
  /// internal [OiTreeController].
  final OiTreeController? controller;

  /// Called when the user taps a node.
  final void Function(OiTreeNode<T> node)? onNodeTap;

  /// Called when the user double-taps a node.
  final void Function(OiTreeNode<T> node)? onNodeDoubleTap;

  /// Called when a node's expansion state changes.
  ///
  /// The boolean argument is `true` when the node expands and `false`
  /// when it collapses.
  final void Function(OiTreeNode<T> node, {required bool expanded})?
  onExpansionChanged;

  /// Called when the selection changes.
  final void Function(Set<String> selectedIds)? onSelectionChanged;

  /// Custom builder for a single node row.
  ///
  /// When `null`, a default row is rendered with an optional leading icon,
  /// an expand/collapse toggle for parent nodes, and the node's [label].
  final Widget Function(
    BuildContext context,
    OiTreeNode<T> node,
    int depth, {
    required bool expanded,
    required bool selected,
  })?
  nodeBuilder;

  /// Indent width in logical pixels per depth level.
  final double indentWidth;

  /// Height of a single node row.
  final double rowHeight;

  /// Whether nodes can be selected by tapping.
  final bool selectable;

  /// Whether multiple nodes may be selected at once.
  final bool multiSelect;

  /// Whether to draw connecting lines between nodes.
  final bool showLines;

  @override
  State<OiTree<T>> createState() => _OiTreeState<T>();
}

class _OiTreeState<T> extends State<OiTree<T>> {
  late OiTreeController _ctrl;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(OiTree<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _disposeControllerIfOwned();
      _initController();
    }
  }

  @override
  void dispose() {
    _disposeControllerIfOwned();
    super.dispose();
  }

  void _initController() {
    if (widget.controller != null) {
      _ctrl = widget.controller!;
      _ownsController = false;
    } else {
      _ctrl = OiTreeController(multiSelect: widget.multiSelect);
      _ownsController = true;
    }
    _ctrl.addListener(_onControllerChanged);
  }

  void _disposeControllerIfOwned() {
    _ctrl.removeListener(_onControllerChanged);
    if (_ownsController) _ctrl.dispose();
  }

  void _onControllerChanged() => setState(() {});

  // ── Flattened render list ─────────────────────────────────────────────────

  /// Flattens the tree to a list of visible (depth, node) pairs.
  List<({int depth, OiTreeNode<T> node})> get _visibleItems {
    final items = <({int depth, OiTreeNode<T> node})>[];
    void visit(OiTreeNode<T> node, int depth) {
      items.add((depth: depth, node: node));
      if (node.hasChildren && _ctrl.expanded(node.id)) {
        for (final child in node.children) {
          visit(child, depth + 1);
        }
      }
    }

    for (final root in widget.nodes) {
      visit(root, 0);
    }
    return items;
  }

  // ── Event handlers ────────────────────────────────────────────────────────

  void _handleTap(OiTreeNode<T> node) {
    if (widget.selectable) {
      if (_ctrl.multiSelect) {
        if (_ctrl.selected(node.id)) {
          _ctrl.deselect(node.id);
        } else {
          _ctrl.select(node.id);
        }
      } else {
        _ctrl.select(node.id);
      }
      widget.onSelectionChanged?.call(Set.from(_ctrl.selectedIds));
    }
    widget.onNodeTap?.call(node);
  }

  void _handleDoubleTap(OiTreeNode<T> node) {
    widget.onNodeDoubleTap?.call(node);
  }

  void _handleToggle(OiTreeNode<T> node) {
    final willExpand = !_ctrl.expanded(node.id);
    _ctrl.toggle(node.id);
    widget.onExpansionChanged?.call(node, expanded: willExpand);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final items = _visibleItems;
    return Semantics(
      label: widget.label,
      explicitChildNodes: true,
      child: ListView.builder(
        itemCount: items.length,
        itemExtent: widget.rowHeight,
        itemBuilder: (ctx, i) {
          final item = items[i];
          return _buildNodeRow(ctx, item.node, item.depth);
        },
      ),
    );
  }

  Widget _buildNodeRow(BuildContext ctx, OiTreeNode<T> node, int depth) {
    final expanded = _ctrl.expanded(node.id);
    final selected = _ctrl.selected(node.id);

    if (widget.nodeBuilder != null) {
      return GestureDetector(
        key: ValueKey('node_${node.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _handleTap(node),
        onDoubleTap: () => _handleDoubleTap(node),
        child: widget.nodeBuilder!(
          ctx,
          node,
          depth,
          expanded: expanded,
          selected: selected,
        ),
      );
    }

    return _DefaultNodeRow<T>(
      key: ValueKey('node_${node.id}'),
      node: node,
      depth: depth,
      expanded: expanded,
      selected: selected,
      indentWidth: widget.indentWidth,
      rowHeight: widget.rowHeight,
      onTap: () => _handleTap(node),
      onDoubleTap: () => _handleDoubleTap(node),
      onToggle: node.hasChildren ? () => _handleToggle(node) : null,
    );
  }
}

// ── Default node row ──────────────────────────────────────────────────────────

class _DefaultNodeRow<T> extends StatelessWidget {
  const _DefaultNodeRow({
    required this.node,
    required this.depth,
    required this.expanded,
    required this.selected,
    required this.indentWidth,
    required this.rowHeight,
    required this.onTap,
    required this.onDoubleTap,
    this.onToggle,
    super.key,
  });

  final OiTreeNode<T> node;
  final int depth;
  final bool expanded;
  final bool selected;
  final double indentWidth;
  final double rowHeight;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    Widget row = Row(
      children: [
        SizedBox(width: depth * indentWidth),
        if (node.hasChildren)
          GestureDetector(
            key: ValueKey('toggle_${node.id}'),
            behavior: HitTestBehavior.opaque,
            onTap: onToggle,
            child: SizedBox(
              width: 24,
              height: rowHeight,
              child: Center(child: Text(expanded ? '▼' : '▶')),
            ),
          )
        else
          SizedBox(width: 24, height: rowHeight),
        if (node.icon != null) ...[node.icon!, const SizedBox(width: 4)],
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              node.label,
              key: ValueKey('label_${node.id}'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );

    if (selected) {
      row = ColoredBox(color: const Color(0xFFDBEAFE), child: row);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: SizedBox(height: rowHeight, child: row),
    );
  }
}
