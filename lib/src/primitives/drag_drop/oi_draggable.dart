import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/primitives/drag_drop/oi_drag_ghost.dart';

/// A widget that makes its [child] draggable, carrying [data] to any
/// compatible [OiDropZone].
///
/// On touch devices ([OiDensity.comfortable]) the drag starts after a long
/// press; on pointer devices the drag starts immediately on press-and-move.
///
/// An optional [feedback] overrides the ghost widget shown under the
/// pointer/finger while dragging. When omitted, [child] is wrapped in an
/// [OiDragGhost].
///
/// {@category Primitives}
class OiDraggable<T extends Object> extends StatelessWidget {
  /// Creates an [OiDraggable].
  const OiDraggable({
    required this.data,
    required this.child,
    this.childWhenDragging,
    this.feedback,
    this.onDragStarted,
    this.onDragEnd,
    this.onDragCompleted,
    this.axis,
    super.key,
  });

  /// The data carried by the drag.
  final T data;

  /// The widget that can be dragged.
  final Widget child;

  /// Widget shown at the original position while dragging is in progress.
  ///
  /// When null, [child] remains visible at its original position.
  final Widget? childWhenDragging;

  /// The drag feedback widget shown under the finger or cursor.
  ///
  /// When null an [OiDragGhost] wrapping [child] is used.
  final Widget? feedback;

  /// Called when the drag starts.
  final VoidCallback? onDragStarted;

  /// Called when the drag ends (regardless of whether it was accepted).
  final VoidCallback? onDragEnd;

  /// Called when the dragged item is dropped on an accepting drop zone.
  final VoidCallback? onDragCompleted;

  /// Restricts dragging to the given [Axis].
  ///
  /// When null, dragging is unconstrained.
  final Axis? axis;

  @override
  Widget build(BuildContext context) {
    final density = OiDensityScope.of(context);
    final isTouch = density == OiDensity.comfortable;

    final effectiveFeedback =
        feedback ?? OiDragGhost(child: child);

    if (isTouch) {
      return LongPressDraggable<T>(
        data: data,
        feedback: effectiveFeedback,
        childWhenDragging: childWhenDragging,
        axis: axis,
        onDragStarted: onDragStarted,
        onDragEnd: onDragEnd != null ? (_) => onDragEnd!() : null,
        onDragCompleted: onDragCompleted,
        child: child,
      );
    } else {
      return Draggable<T>(
        data: data,
        feedback: effectiveFeedback,
        childWhenDragging: childWhenDragging,
        axis: axis,
        onDragStarted: onDragStarted,
        onDragEnd: onDragEnd != null ? (_) => onDragEnd!() : null,
        onDragCompleted: onDragCompleted,
        child: child,
      );
    }
  }
}
