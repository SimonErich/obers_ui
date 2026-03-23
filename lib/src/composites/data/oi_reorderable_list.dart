import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/drag_drop/oi_drag_ghost.dart';

/// A drag-to-reorder list that supports drag handles, long-press drag,
/// keyboard reordering, and animated gap insertion.
///
/// Each item is built by [itemBuilder] which receives the item, its index,
/// and an optional drag handle widget. The [onReorder] callback is invoked
/// with the old and new indices when an item is dropped in a new position.
///
/// Drag modes:
/// - [dragHandle] = `true` (default): a grip icon is passed to the builder
///   and only that widget initiates the drag.
/// - [dragHandle] = `false`, [longPressDrag] = `true`: the entire item
///   becomes draggable via long press.
/// - [dragHandle] = `false`, [longPressDrag] = `false`: the entire item
///   is immediately draggable.
///
/// Keyboard support: focus an item and press Space to pick it up,
/// Arrow keys to move, Enter to drop, Escape to cancel.
///
/// {@category Composites}
class OiReorderableList<T> extends StatefulWidget {
  /// Creates an [OiReorderableList].
  const OiReorderableList({
    required this.items,
    required this.itemBuilder,
    required this.onReorder,
    this.itemKey,
    this.dragHandle = true,
    this.longPressDrag = false,
    this.axis = Axis.vertical,
    this.padding,
    this.separator,
    this.shrinkWrap = false,
    this.onDragStart,
    this.onDragEnd,
    this.canReorder,
    this.semanticLabel,
    super.key,
  });

  /// The data items to display.
  final List<T> items;

  /// Builds the widget for each item.
  ///
  /// The [dragHandle] parameter is a pre-built grip widget when
  /// [OiReorderableList.dragHandle] is `true`, or `null` otherwise.
  /// Place it wherever you want the drag handle to appear.
  final Widget Function(
    BuildContext context,
    T item,
    int index,
    Widget? dragHandle,
  ) itemBuilder;

  /// Called when the user drops an item at a new position.
  final void Function(int oldIndex, int newIndex) onReorder;

  /// Extracts a unique key for each item. When null, the item index is used.
  final ValueKey<Object> Function(T item)? itemKey;

  /// Whether to show a drag handle icon on each item.
  ///
  /// Defaults to `true`.
  final bool dragHandle;

  /// Whether dragging requires a long press (when [dragHandle] is `false`).
  ///
  /// Defaults to `false`.
  final bool longPressDrag;

  /// The scroll axis of the list.
  ///
  /// Defaults to [Axis.vertical].
  final Axis axis;

  /// Padding around the list.
  final EdgeInsetsGeometry? padding;

  /// An optional separator widget placed between items.
  final Widget? separator;

  /// Whether the list wraps its content tightly.
  ///
  /// When `true`, the list can be placed inside unbounded-height containers
  /// such as [Column].
  final bool shrinkWrap;

  /// Called when a drag operation starts.
  final void Function(int index)? onDragStart;

  /// Called when a drag operation ends.
  final void Function(int index)? onDragEnd;

  /// A predicate controlling which items can be dragged.
  ///
  /// Return `false` to prevent the item at the given index from being
  /// reordered. When null, all items are reorderable.
  final bool Function(int index)? canReorder;

  /// An accessibility label for the reorderable list.
  final String? semanticLabel;

  @override
  State<OiReorderableList<T>> createState() => _OiReorderableListState<T>();
}

class _OiReorderableListState<T> extends State<OiReorderableList<T>>
    with TickerProviderStateMixin {
  int? _dragIndex;
  int? _hoverIndex;
  int? _keyboardPickedIndex;
  int? _keyboardTargetIndex;

  ValueKey<Object> _keyForIndex(int index) {
    if (widget.itemKey != null) {
      return widget.itemKey!(widget.items[index]);
    }
    return ValueKey<Object>(index);
  }

  bool _canReorder(int index) {
    return widget.canReorder?.call(index) ?? true;
  }

  // ── Keyboard reordering ──────────────────────────────────────────────────

  void _handleKeyEvent(int index, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return;

    final key = event.logicalKey;

    if (_keyboardPickedIndex != null) {
      // Item is picked up — handle movement keys.
      if (key == LogicalKeyboardKey.escape) {
        setState(() {
          _keyboardPickedIndex = null;
          _keyboardTargetIndex = null;
        });
        return;
      }

      final target = _keyboardTargetIndex ?? _keyboardPickedIndex!;
      final isVertical = widget.axis == Axis.vertical;
      final forward = isVertical
          ? key == LogicalKeyboardKey.arrowDown
          : key == LogicalKeyboardKey.arrowRight;
      final backward = isVertical
          ? key == LogicalKeyboardKey.arrowUp
          : key == LogicalKeyboardKey.arrowLeft;

      if (forward && target < widget.items.length - 1) {
        setState(() => _keyboardTargetIndex = target + 1);
        return;
      }
      if (backward && target > 0) {
        setState(() => _keyboardTargetIndex = target - 1);
        return;
      }
      if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
        final from = _keyboardPickedIndex!;
        final to = _keyboardTargetIndex ?? from;
        setState(() {
          _keyboardPickedIndex = null;
          _keyboardTargetIndex = null;
        });
        if (from != to) {
          widget.onReorder(from, to);
        }
        return;
      }
    } else {
      // No item picked up — Space to pick up.
      if (key == LogicalKeyboardKey.space && _canReorder(index)) {
        setState(() {
          _keyboardPickedIndex = index;
          _keyboardTargetIndex = index;
        });
        return;
      }
    }
  }

  // ── Drag handle builder ──────────────────────────────────────────────────

  Widget _buildDragHandle(BuildContext context) {
    final colors = context.colors;
    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OiIcon.decorative(
          icon: OiIcons.gripVertical,
          size: 16,
          color: colors.textMuted,
        ),
      ),
    );
  }

  // ── Item wrapper ─────────────────────────────────────────────────────────

  Widget _buildItem(BuildContext context, int index) {
    final colors = context.colors;
    final spacing = context.spacing;
    final animations = context.animations;
    final item = widget.items[index];
    final reorderable = _canReorder(index);

    // Build the drag handle if requested.
    Widget? handleWidget;
    if (widget.dragHandle && reorderable) {
      handleWidget = _buildDragHandle(context);
    }

    // Build the item content.
    var child = widget.itemBuilder(context, item, index, handleWidget);

    // Add separator below if provided.
    if (widget.separator != null && index < widget.items.length - 1) {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          child,
          widget.separator!,
        ],
      );
    }

    // Keyboard-picked highlight.
    final isKeyboardPicked = _keyboardPickedIndex == index;
    final isKeyboardTarget = _keyboardTargetIndex == index &&
        _keyboardPickedIndex != null &&
        _keyboardTargetIndex != _keyboardPickedIndex;

    if (isKeyboardPicked) {
      child = DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: colors.borderFocus, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: child,
      );
    } else if (isKeyboardTarget) {
      child = DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceHover,
          borderRadius: BorderRadius.circular(4),
        ),
        child: child,
      );
    }

    // Wrap with Focus for keyboard support.
    child = Focus(
      onKeyEvent: (node, event) {
        _handleKeyEvent(index, event);
        if (_keyboardPickedIndex != null) {
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );

    // Wrap the item with drag/drop behavior.
    if (!reorderable) {
      return DragTarget<int>(
        key: _keyForIndex(index),
        onWillAcceptWithDetails: (details) {
          _updateHover(index);
          return true;
        },
        onLeave: (_) => _clearHover(index),
        onAcceptWithDetails: (details) => _handleDrop(details.data, index),
        builder: (context, _, __) => child,
      );
    }

    // Create the feedback widget.
    Widget feedbackBuilder() {
      return OiDragGhost(
        child: SizedBox(
          width: _getItemWidth(context),
          child: DefaultTextStyle(
            style: DefaultTextStyle.of(context).style,
            child: widget.itemBuilder(context, item, index, handleWidget),
          ),
        ),
      );
    }

    // Gap animation for hover position.
    final showGapAbove = _hoverIndex == index && _dragIndex != null;

    final itemContent = AnimatedContainer(
      duration: animations.fast,
      curve: Curves.easeOutCubic,
      padding: showGapAbove
          ? EdgeInsets.only(
              top: widget.axis == Axis.vertical ? spacing.xxl : 0,
              left: widget.axis == Axis.horizontal ? spacing.xxl : 0,
            )
          : EdgeInsets.zero,
      child: child,
    );

    // Placeholder when this item is being dragged.
    final childWhenDragging = AnimatedOpacity(
      opacity: 0,
      duration: animations.fast,
      child: IgnorePointer(child: child),
    );

    Widget result;

    if (widget.dragHandle) {
      // Drag is initiated from the handle only; we wrap the entire item
      // in a DragTarget + Draggable.
      result = DragTarget<int>(
        key: _keyForIndex(index),
        onWillAcceptWithDetails: (details) {
          _updateHover(index);
          return true;
        },
        onLeave: (_) => _clearHover(index),
        onAcceptWithDetails: (details) => _handleDrop(details.data, index),
        builder: (context, _, __) {
          return Draggable<int>(
            data: index,
            axis: widget.axis,
            feedback: feedbackBuilder(),
            childWhenDragging: childWhenDragging,
            onDragStarted: () => _onDragStarted(index),
            onDragEnd: (_) => _onDragEnded(index),
            child: itemContent,
          );
        },
      );
    } else if (widget.longPressDrag) {
      result = DragTarget<int>(
        key: _keyForIndex(index),
        onWillAcceptWithDetails: (details) {
          _updateHover(index);
          return true;
        },
        onLeave: (_) => _clearHover(index),
        onAcceptWithDetails: (details) => _handleDrop(details.data, index),
        builder: (context, _, __) {
          return LongPressDraggable<int>(
            data: index,
            axis: widget.axis,
            feedback: feedbackBuilder(),
            childWhenDragging: childWhenDragging,
            onDragStarted: () => _onDragStarted(index),
            onDragEnd: (_) => _onDragEnded(index),
            child: itemContent,
          );
        },
      );
    } else {
      result = DragTarget<int>(
        key: _keyForIndex(index),
        onWillAcceptWithDetails: (details) {
          _updateHover(index);
          return true;
        },
        onLeave: (_) => _clearHover(index),
        onAcceptWithDetails: (details) => _handleDrop(details.data, index),
        builder: (context, _, __) {
          return Draggable<int>(
            data: index,
            axis: widget.axis,
            feedback: feedbackBuilder(),
            childWhenDragging: childWhenDragging,
            onDragStarted: () => _onDragStarted(index),
            onDragEnd: (_) => _onDragEnded(index),
            child: itemContent,
          );
        },
      );
    }

    return result;
  }

  double? _getItemWidth(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      return renderBox.size.width;
    }
    return null;
  }

  // ── Drag state management ────────────────────────────────────────────────

  void _onDragStarted(int index) {
    setState(() => _dragIndex = index);
    widget.onDragStart?.call(index);
  }

  void _onDragEnded(int index) {
    setState(() {
      _dragIndex = null;
      _hoverIndex = null;
    });
    widget.onDragEnd?.call(index);
  }

  void _updateHover(int index) {
    if (_hoverIndex != index) {
      setState(() => _hoverIndex = index);
    }
  }

  void _clearHover(int index) {
    if (_hoverIndex == index) {
      setState(() => _hoverIndex = null);
    }
  }

  void _handleDrop(int fromIndex, int toIndex) {
    setState(() {
      _dragIndex = null;
      _hoverIndex = null;
    });
    if (fromIndex != toIndex) {
      widget.onReorder(fromIndex, toIndex);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    Widget list;

    if (widget.shrinkWrap) {
      // Use a Column for shrink-wrapped layout.
      final children = <Widget>[
        for (var i = 0; i < widget.items.length; i++) _buildItem(context, i),
      ];

      if (widget.axis == Axis.vertical) {
        list = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        );
      } else {
        list = Row(
          mainAxisSize: MainAxisSize.min,
          children: children,
        );
      }
    } else {
      list = ListView.builder(
        scrollDirection: widget.axis,
        padding: widget.padding,
        itemCount: widget.items.length,
        itemBuilder: _buildItem,
      );
    }

    if (widget.shrinkWrap && widget.padding != null) {
      list = Padding(padding: widget.padding!, child: list);
    }

    if (widget.semanticLabel != null) {
      list = Semantics(
        label: widget.semanticLabel,
        container: true,
        child: list,
      );
    }

    return list;
  }
}
