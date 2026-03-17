import 'package:flutter/widgets.dart';

/// The state of a [OiDropZone] with respect to an active drag.
///
/// {@category Primitives}
enum OiDropState {
  /// No drag is currently over this zone.
  idle,

  /// A compatible drag is hovering over this zone.
  hovering,

  /// A drag was accepted and dropped on this zone.
  accepted,

  /// A drag is hovering but its data was rejected by [OiDropZone.onWillAccept].
  rejected,
}

/// A widget that accepts dragged items from an [OiDraggable].
///
/// The [builder] is called with the current [OiDropState] so that the drop
/// zone can update its appearance in response to incoming drags. [onAccept] is
/// called with the dropped data when the user releases a compatible drag over
/// this zone.
///
/// {@category Primitives}
class OiDropZone<T extends Object> extends StatefulWidget {
  /// Creates an [OiDropZone].
  const OiDropZone({
    required this.onAccept,
    required this.builder,
    this.onWillAccept,
    super.key,
  });

  /// Called to determine whether incoming [data] is accepted by this zone.
  ///
  /// Return `true` to accept the drag (state becomes [OiDropState.hovering]);
  /// return `false` to reject it (state becomes [OiDropState.rejected]).
  /// When null every drag is accepted.
  final bool Function(T? data)? onWillAccept;

  /// Called with the dropped data when a drag is accepted.
  final void Function(T data) onAccept;

  /// Builder that receives the current [OiDropState] and returns the child
  /// widget to display.
  final Widget Function(BuildContext context, OiDropState state) builder;

  @override
  State<OiDropZone<T>> createState() => _OiDropZoneState<T>();
}

class _OiDropZoneState<T extends Object> extends State<OiDropZone<T>> {
  OiDropState _state = OiDropState.idle;

  void _setState(OiDropState next) {
    if (_state != next) setState(() => _state = next);
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<T>(
      onWillAcceptWithDetails: (details) {
        final accepted = widget.onWillAccept?.call(details.data) ?? true;
        _setState(accepted ? OiDropState.hovering : OiDropState.rejected);
        return accepted;
      },
      onMove: (details) {
        final accepted = widget.onWillAccept?.call(details.data) ?? true;
        _setState(accepted ? OiDropState.hovering : OiDropState.rejected);
      },
      onLeave: (_) => _setState(OiDropState.idle),
      onAcceptWithDetails: (details) {
        widget.onAccept(details.data);
        _setState(OiDropState.idle);
      },
      builder: (context, _, __) => widget.builder(context, _state),
    );
  }
}
