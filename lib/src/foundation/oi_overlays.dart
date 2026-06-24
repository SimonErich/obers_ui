import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiApp;
import 'package:obers_ui/src/foundation/oi_app.dart' show OiApp;

/// Z-order layers for overlay entries.
///
/// Higher values render above lower values.
///
/// {@category Foundation}
enum OiOverlayZOrder {
  /// Base-level overlays (dropdowns, tooltips anchored to widgets).
  base,

  /// Floating dropdowns and select menus.
  dropdown,

  /// Tooltip overlays.
  tooltip,

  /// Side panels and drawers.
  panel,

  /// Modal dialogs.
  dialog,

  /// Toast notifications.
  toast,

  /// Critical system overlays (e.g. permission dialogs).
  critical,
}

/// A handle returned when an overlay is shown.
///
/// Use [dismiss] to close the overlay programmatically.
/// Use [update] to rebuild the overlay content.
///
/// {@category Foundation}
class OiOverlayHandle {
  /// Creates an [OiOverlayHandle] backed by the given [_entry].
  OiOverlayHandle._(this._entry);

  final OverlayEntry _entry;

  bool _dismissed = false;

  /// Callback invoked when the handle is dismissed, used by the service
  /// to eagerly remove the handle from its tracking lists.
  VoidCallback? _onDismiss;

  /// Whether this overlay has been dismissed.
  bool get isDismissed => _dismissed;

  /// Removes the overlay from the screen.
  void dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    _onDismiss?.call();
    _onDismiss = null;
    _entry.remove();
  }

  /// Marks the overlay entry as needing a rebuild.
  void update() {
    if (_dismissed) return;
    _entry.markNeedsBuild();
  }
}

/// The overlay management service for the obers_ui design system.
///
/// Shows overlays (dialogs, toasts, panels, etc.) above all other content
/// via [OiOverlays.of]. The service is provided by [OiApp] through
/// [buildOiOverlaysHost].
///
/// {@category Foundation}
class OiOverlaysService {
  OiOverlaysService._();

  OverlayState? _overlayState;
  final List<OiOverlayHandle> _activeHandles = [];
  final List<OiOverlayHandle> _scrollDismissHandles = [];

  /// Shows a custom overlay widget above all content.
  ///
  /// The [label] is announced by screen readers when the overlay appears.
  ///
  /// When [dismissOnScroll] is `true`, the overlay is automatically dismissed
  /// when any scrollable in the content tree scrolls. This is appropriate for
  /// lightweight overlays like dropdowns and context menus, but not for modal
  /// dialogs or persistent notifications.
  ///
  /// Returns an [OiOverlayHandle] that can be used to dismiss or update
  /// the overlay.
  OiOverlayHandle show({
    required String label,
    required WidgetBuilder builder,
    OiOverlayZOrder zOrder = OiOverlayZOrder.base,
    bool dismissible = true,
    bool dismissOnScroll = false,
    VoidCallback? onDismiss,
  }) {
    final overlayState = _overlayState;
    assert(
      overlayState != null && overlayState.mounted,
      'OiOverlays not attached to a mounted OverlayState',
    );

    late OiOverlayHandle handle;
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        Widget content;
        if (dismissible) {
          content = Stack(
            children: [
              // Barrier that dismisses on tap but lets scroll gestures
              // pass through so the background can still scroll.
              Positioned.fill(
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: (_) {
                    onDismiss?.call();
                    handle.dismiss();
                  },
                ),
              ),
              builder(context),
            ],
          );
        } else {
          content = builder(context);
        }
        return Semantics(
          label: label,
          scopesRoute: true,
          explicitChildNodes: true,
          child: content,
        );
      },
    );

    handle = OiOverlayHandle._(entry);
    _activeHandles.add(handle);
    if (dismissOnScroll) _scrollDismissHandles.add(handle);
    handle._onDismiss = () {
      _activeHandles.remove(handle);
      _scrollDismissHandles.remove(handle);
    };
    overlayState!.insert(entry);

    return handle;
  }

  /// Called by the overlay host when a scroll notification is detected
  /// in the content tree. Dismisses all overlays that opted into
  /// dismissOnScroll.
  void _handleContentScroll() {
    // Copy the list — dismiss() mutates _scrollDismissHandles via _onDismiss.
    final handles = List<OiOverlayHandle>.of(_scrollDismissHandles);
    for (final h in handles) {
      h.dismiss();
    }
  }

  /// Dismisses all active overlays.
  void dismissAll() {
    // Copy the list — dismiss() mutates _activeHandles via _onDismiss.
    for (final h in List<OiOverlayHandle>.of(_activeHandles)) {
      h.dismiss();
    }
  }
}

/// Provides the [OiOverlaysService] to all descendants.
///
/// Access via [OiOverlays.of].
///
/// {@category Foundation}
class OiOverlays extends InheritedWidget {
  /// Creates an [OiOverlays] provider.
  const OiOverlays({required this.service, required super.child, super.key});

  /// The overlay service.
  final OiOverlaysService service;

  /// Returns the [OiOverlaysService] from the nearest [OiOverlays].
  ///
  /// Throws if no [OiOverlays] is found in the tree.
  static OiOverlaysService of(BuildContext context) {
    final overlays = maybeOf(context);
    assert(
      overlays != null,
      'No OiOverlays found in the widget tree. '
      'Ensure OiApp wraps your widget.',
    );
    return overlays!;
  }

  /// Returns the [OiOverlaysService], or null if not found.
  static OiOverlaysService? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<OiOverlays>()?.service;
  }

  @override
  bool updateShouldNotify(OiOverlays oldWidget) => service != oldWidget.service;
}

/// Internal host widget that provides overlay capabilities to the app.
///
/// App content is a normal [Stack] child. Dialogs/toasts use a dedicated empty
/// [Overlay] on top — never an [OverlayEntry] for content, which breaks when
/// keyboard inset / [MediaQuery] changes call [OverlayEntry.markNeedsBuild].
///
/// This widget is rendered internally by [OiApp] and is not exported.
class _OiOverlaysHost extends StatefulWidget {
  const _OiOverlaysHost({
    required this.service,
    required this.child,
  });

  final OiOverlaysService service;
  final Widget child;

  @override
  State<_OiOverlaysHost> createState() => _OiOverlaysHostState();
}

class _OiOverlaysHostState extends State<_OiOverlaysHost> {
  final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>(
    debugLabel: 'OiOverlaysHost',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _attachOverlayState());
  }

  @override
  void dispose() {
    widget.service._overlayState = null;
    super.dispose();
  }

  void _attachOverlayState() {
    if (!mounted) return;
    widget.service._overlayState = _overlayKey.currentState;
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      widget.service._handleContentScroll();
    }
    return false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _attachOverlayState());
  }

  @override
  Widget build(BuildContext context) {
    final content = NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: widget.child,
    );

    return OiOverlays(
      service: widget.service,
      child: Stack(
        children: [
          content,
          Positioned.fill(
            child: Overlay(key: _overlayKey),
          ),
        ],
      ),
    );
  }
}

/// Public factory for creating an overlay host. Used by [OiApp].
Widget buildOiOverlaysHost({
  required OiOverlaysService service,
  required Widget child,
}) {
  return _OiOverlaysHost(
    service: service,
    child: child,
  );
}

/// Creates a fresh [OiOverlaysService] instance.
OiOverlaysService createOiOverlaysService() => OiOverlaysService._();

/// Creates an [OiOverlayHandle] backed by a raw [OverlayEntry].
///
/// Used by components that need to insert overlay entries directly (e.g. as a
/// fallback when no [OiOverlays] ancestor is present in the widget tree).
OiOverlayHandle createOiOverlayHandle(OverlayEntry entry) =>
    OiOverlayHandle._(entry);
