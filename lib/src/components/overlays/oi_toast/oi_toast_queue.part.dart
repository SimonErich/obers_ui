part of '../oi_toast.dart';

// ── Toast queue manager ──────────────────────────────────────────────────────

/// Manages a single overlay entry that renders all active toasts in a column.
class _OiToastQueue {
  _OiToastQueue._();

  static _OiToastQueue? _instance;
  // A getter is used here to lazily initialise the singleton; a Dart factory
  // constructor cannot conditionally return an already-created instance.
  // ignore: prefer_constructors_over_static_methods
  static _OiToastQueue get _shared => _instance ??= _OiToastQueue._();

  OiOverlayHandle? _handle;
  final List<_OiToastEntry> _entries = [];
  final _notifier = _ToastQueueNotifier();

  OiOverlayHandle addToast(
    BuildContext context, {
    required String message,
    required OiToastLevel level,
    required OiToastPosition position,
    required Duration? duration,
    required bool pauseOnHover,
    required bool dismissible,
    required String dismissLabel,
    Widget? action,
    VoidCallback? onDismiss,
  }) {
    if (_handle?.isDismissed ?? false) {
      for (final entry in _entries) {
        entry._dismissed = true;
      }
      _entries.clear();
      _handle = null;
    }

    final entry = _OiToastEntry(
      message: message,
      level: level,
      position: position,
      duration: duration,
      pauseOnHover: pauseOnHover,
      dismissible: dismissible,
      dismissLabel: dismissLabel,
      action: action,
      onDismiss: onDismiss,
    );
    _entries.add(entry);

    if (_handle == null || _handle!.isDismissed) {
      _createOverlay(context, position);
    } else {
      _handle!.update();
    }
    entry._overlay = _handle!;
    _notifier.notify();

    // Return a handle that removes this specific entry.
    return _OiSingleToastHandle(
      entry: entry,
      onDismiss: () => _removeEntry(entry),
    );
  }

  void _removeEntry(_OiToastEntry entry) {
    if (entry._dismissed) return;
    entry._dismissed = true;
    _entries.remove(entry);
    if (_entries.isEmpty) {
      _handle?.dismiss();
      _handle = null;
    } else {
      _handle?.update();
    }
    _notifier.notify();
  }

  void _createOverlay(BuildContext context, OiToastPosition position) {
    final service = OiOverlays.maybeOf(context);

    Widget builder(BuildContext _) => ListenableBuilder(
      listenable: _notifier,
      builder: (ctx, _) => _OiToastGroups(
        entries: List.of(_entries),
        onEntryDismissed: _removeEntry,
      ),
    );

    if (service != null) {
      _handle = service.show(
        label: 'Toast notifications',
        builder: builder,
        zOrder: OiOverlayZOrder.toast,
        dismissible: false,
      );
    } else {
      final entry = OverlayEntry(builder: builder);
      Overlay.of(context).insert(entry);
      _handle = createOiOverlayHandle(entry);
    }
  }
}

class _ToastQueueNotifier extends ChangeNotifier {
  // Intentional notify wrapper to keep the public API surface minimal.
  void notify() => notifyListeners();
}

/// Data for a single queued toast.
class _OiToastEntry {
  _OiToastEntry({
    required this.message,
    required this.level,
    required this.position,
    required this.duration,
    required this.pauseOnHover,
    required this.dismissible,
    required this.dismissLabel,
    this.action,
    this.onDismiss,
  });

  final String message;
  final OiToastLevel level;
  final OiToastPosition position;
  final Duration? duration;
  final bool pauseOnHover;
  final bool dismissible;
  final String dismissLabel;
  final Widget? action;
  final VoidCallback? onDismiss;
  bool _dismissed = false;
  late final OiOverlayHandle _overlay;

  bool get _isDismissed => _dismissed || _overlay.isDismissed;
}

/// A fake handle that dismisses a single entry from the queue.
class _OiSingleToastHandle implements OiOverlayHandle {
  _OiSingleToastHandle({
    required _OiToastEntry entry,
    required VoidCallback onDismiss,
  }) : _entry = entry,
       _onDismiss = onDismiss;

  final VoidCallback _onDismiss;
  final _OiToastEntry _entry;

  @override
  bool get isDismissed => _entry._isDismissed;

  @override
  void dismiss() {
    if (isDismissed) return;
    _onDismiss();
  }

  @override
  void update() {}
}
