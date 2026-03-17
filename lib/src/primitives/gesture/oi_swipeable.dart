import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// An action revealed when swiping a list item.
///
/// Each [OiSwipeAction] defines the [label], [color], optional [icon], and
/// [onTap] callback that is triggered when the user activates the action.
class OiSwipeAction {
  /// Creates an [OiSwipeAction].
  const OiSwipeAction({
    required this.label,
    required this.color,
    required this.onTap,
    this.icon,
  });

  /// Label for the action.
  final String label;

  /// Background color of the action tile.
  final Color color;

  /// Optional icon displayed alongside the [label].
  final IconData? icon;

  /// Callback invoked when the action is triggered.
  final VoidCallback onTap;
}

/// A widget that reveals swipe actions behind its [child] when dragged
/// horizontally.
///
/// Dragging right (positive delta) reveals [leadingActions]; dragging left
/// (negative delta) reveals [trailingActions]. Each action is shown as a
/// coloured tile behind the child. When [dismissible] is `true` and the drag
/// distance exceeds `threshold * itemWidth`, [onDismissed] is called and the
/// child is removed.
///
/// ```dart
/// OiSwipeable(
///   leadingActions: [
///     OiSwipeAction(label: 'Archive', color: Color(0xFF4CAF50), onTap: _archive),
///   ],
///   trailingActions: [
///     OiSwipeAction(label: 'Delete', color: Color(0xFFF44336), onTap: _delete),
///   ],
///   child: ListTile(title: Text('Item')),
/// )
/// ```
///
/// {@category Primitives}
class OiSwipeable extends StatefulWidget {
  /// Creates an [OiSwipeable].
  const OiSwipeable({
    required this.child,
    this.leadingActions = const [],
    this.trailingActions = const [],
    this.threshold = 0.4,
    this.dismissible = false,
    this.onDismissed,
    super.key,
  });

  /// The main content displayed over the actions.
  final Widget child;

  /// Actions revealed on a left-to-right swipe.
  final List<OiSwipeAction> leadingActions;

  /// Actions revealed on a right-to-left swipe.
  final List<OiSwipeAction> trailingActions;

  /// Fraction of the item width (0–1) at which an action is considered
  /// triggered, or at which the item is dismissed when [dismissible] is `true`.
  ///
  /// Defaults to `0.4`.
  final double threshold;

  /// Whether the item can be fully swiped away to trigger [onDismissed].
  ///
  /// Defaults to `false`.
  final bool dismissible;

  /// Called when the item is dismissed (requires [dismissible] to be `true`).
  final VoidCallback? onDismissed;

  @override
  State<OiSwipeable> createState() => _OiSwipeableState();
}

class _OiSwipeableState extends State<OiSwipeable> {
  double _dragOffset = 0;
  bool _dismissed = false;

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_dismissed) return;
    setState(() {
      _dragOffset += details.delta.dx;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dismissed) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final itemWidth = box.size.width;

    if (widget.dismissible &&
        _dragOffset.abs() >= widget.threshold * itemWidth) {
      setState(() => _dismissed = true);
      widget.onDismissed?.call();
      return;
    }

    // Snap back.
    setState(() => _dragOffset = 0);
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final showLeading =
        _dragOffset > 0 && widget.leadingActions.isNotEmpty;
    final showTrailing =
        _dragOffset < 0 && widget.trailingActions.isNotEmpty;

    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      dragStartBehavior: DragStartBehavior.down,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          // Action background layer.
          if (showLeading)
            Positioned.fill(
              child: Row(
                children: widget.leadingActions
                    .map(
                      (action) => Expanded(
                        child: GestureDetector(
                          onTap: action.onTap,
                          child: ColoredBox(
                            color: action.color,
                            child: Center(child: Text(action.label)),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          if (showTrailing)
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: widget.trailingActions
                    .map(
                      (action) => Expanded(
                        child: GestureDetector(
                          onTap: action.onTap,
                          child: ColoredBox(
                            color: action.color,
                            child: Center(child: Text(action.label)),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          // Sliding child.
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
