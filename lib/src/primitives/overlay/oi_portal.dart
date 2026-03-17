import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Renders its [child] inside the nearest [Overlay] when [active] is true.
///
/// This is useful for "portalling" content out of its DOM-like position in the
/// widget tree so that it appears above all other content (e.g. tooltips,
/// dropdowns, menus). When [active] is false, nothing is rendered in the
/// overlay.
///
/// The portal requires an [Overlay] ancestor in the widget tree (provided
/// automatically by [OiApp] via [Navigator] / [WidgetsApp]).
///
/// ```dart
/// OiPortal(
///   active: _showMenu,
///   child: MenuPanel(...),
/// )
/// ```
///
/// {@category Primitives}
class OiPortal extends StatefulWidget {
  /// Creates an [OiPortal].
  const OiPortal({
    required this.child,
    this.active = false,
    super.key,
  });

  /// The widget to render in the overlay when [active] is true.
  final Widget child;

  /// Whether the portal is currently active (rendering in the overlay).
  ///
  /// When changed from false to true the [child] is inserted into the overlay.
  /// When changed from true to false the overlay entry is removed.
  final bool active;

  @override
  State<OiPortal> createState() => _OiPortalState();
}

class _OiPortalState extends State<OiPortal> {
  OverlayEntry? _entry;

  @override
  void initState() {
    super.initState();
    if (widget.active) {
      // Defer insert so it never runs while the framework is building.
      _scheduleInsert();
    }
  }

  @override
  void didUpdateWidget(OiPortal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      if (widget.active) {
        _scheduleInsert();
      } else {
        // Defer removal to avoid modifying the overlay during a build.
        _scheduleRemove();
      }
    } else if (widget.active && widget.child != oldWidget.child) {
      // Defer markNeedsBuild to avoid calling it during a build phase.
      _scheduleMarkNeedsBuild();
    }
  }

  @override
  void dispose() {
    _doRemoveEntry();
    super.dispose();
  }

  void _scheduleInsert() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.active) {
        _doInsertEntry();
      }
    });
  }

  void _scheduleRemove() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted && !widget.active) {
        _doRemoveEntry();
      }
    });
  }

  void _scheduleMarkNeedsBuild() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _entry?.markNeedsBuild();
      }
    });
  }

  void _doInsertEntry() {
    if (_entry != null) {
      _entry!.markNeedsBuild();
      return;
    }
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    _entry = OverlayEntry(builder: (_) => widget.child);
    overlay.insert(_entry!);
  }

  void _doRemoveEntry() {
    _entry?.remove();
    _entry?.dispose();
    _entry = null;
  }

  @override
  Widget build(BuildContext context) {
    // The portal itself is invisible in-tree; content lives in the overlay.
    return const SizedBox.shrink();
  }
}
