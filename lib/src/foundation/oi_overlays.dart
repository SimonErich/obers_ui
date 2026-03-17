import 'package:flutter/widgets.dart';

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

  /// Whether this overlay has been dismissed.
  bool get isDismissed => _dismissed;

  /// Removes the overlay from the screen.
  void dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    _entry
      ..remove()
      ..dispose();
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

  /// Shows a custom overlay widget above all content.
  ///
  /// Returns an [OiOverlayHandle] that can be used to dismiss or update
  /// the overlay.
  OiOverlayHandle show({
    required WidgetBuilder builder,
    OiOverlayZOrder zOrder = OiOverlayZOrder.base,
    bool dismissible = true,
    VoidCallback? onDismiss,
  }) {
    assert(_overlayState != null, 'OiOverlays not attached to OverlayState');

    late OiOverlayHandle handle;
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        if (dismissible) {
          return Stack(
            children: [
              // Invisible dismiss barrier
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    onDismiss?.call();
                    handle.dismiss();
                  },
                  child: const SizedBox.expand(),
                ),
              ),
              builder(context),
            ],
          );
        }
        return builder(context);
      },
    );

    handle = OiOverlayHandle._(entry);
    _activeHandles.add(handle);
    _overlayState!.insert(entry);

    return handle;
  }

  /// Dismisses all active overlays.
  void dismissAll() {
    // Copy list to avoid modification during iteration
    for (final h in List<OiOverlayHandle>.of(_activeHandles)) {
      h.dismiss();
    }
    _activeHandles.removeWhere((h) => h.isDismissed);
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

/// Internal host widget that creates the [Overlay] and attaches the service.
///
/// This widget is rendered internally by [OiApp] and is not exported.
class _OiOverlaysHost extends StatefulWidget {
  const _OiOverlaysHost({required this.service, required this.child});

  final OiOverlaysService service;
  final Widget child;

  @override
  State<_OiOverlaysHost> createState() => _OiOverlaysHostState();
}

class _OiOverlaysHostState extends State<_OiOverlaysHost> {
  late final GlobalKey<OverlayState> _overlayKey;

  @override
  void initState() {
    super.initState();
    _overlayKey = GlobalKey<OverlayState>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Attach once the overlay is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = _overlayKey.currentState;
      if (state != null) {
        widget.service._overlayState = state;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OiOverlays(
      service: widget.service,
      child: Overlay(
        key: _overlayKey,
        initialEntries: [OverlayEntry(builder: (_) => widget.child)],
      ),
    );
  }
}

/// Public factory for creating an overlay host. Used by [OiApp].
Widget buildOiOverlaysHost({
  required OiOverlaysService service,
  required Widget child,
}) {
  return _OiOverlaysHost(service: service, child: child);
}

/// Creates a fresh [OiOverlaysService] instance.
OiOverlaysService createOiOverlaysService() => OiOverlaysService._();

/// Creates an [OiOverlayHandle] backed by a raw [OverlayEntry].
///
/// Used by components that need to insert overlay entries directly (e.g. as a
/// fallback when no [OiOverlays] ancestor is present in the widget tree).
OiOverlayHandle createOiOverlayHandle(OverlayEntry entry) =>
    OiOverlayHandle._(entry);
