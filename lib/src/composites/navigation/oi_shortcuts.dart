import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// ── Shortcut activator ──────────────────────────────────────────────────────

/// Platform-aware keyboard shortcut activator.
///
/// Automatically maps [LogicalKeyboardKey] modifiers:
/// - `Ctrl` maps to `Cmd` on macOS/iOS
/// - `Ctrl` stays `Ctrl` on Windows/Linux/Web
///
/// {@category Composites}
class OiShortcutActivator extends SingleActivator {
  /// Creates an [OiShortcutActivator] with explicit modifier flags.
  ///
  /// Prefer [OiShortcutActivator.primary] for platform-adaptive shortcuts.
  const OiShortcutActivator(
    super.trigger, {
    super.control,
    super.shift,
    super.alt,
    super.meta,
  });

  /// Creates a shortcut using the primary modifier (Ctrl/Cmd).
  ///
  /// On macOS and iOS the primary modifier is `Cmd` (meta); on all other
  /// platforms it is `Ctrl` (control).
  factory OiShortcutActivator.primary(
    LogicalKeyboardKey key, {
    bool shift = false,
    bool alt = false,
  }) {
    final useMeta = _isApplePlatform;
    return OiShortcutActivator(
      key,
      control: !useMeta,
      meta: useMeta,
      shift: shift,
      alt: alt,
    );
  }

  /// Whether the current platform uses Cmd instead of Ctrl.
  static bool get _isApplePlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Human-readable display label for this shortcut.
  ///
  /// Returns a platform-appropriate string such as `"Cmd+Z"` on macOS or
  /// `"Ctrl+Z"` on other platforms.
  String get displayLabel {
    final parts = <String>[];

    if (control) {
      parts.add(_isApplePlatform ? 'Ctrl' : 'Ctrl');
    }
    if (meta) {
      parts.add(_isApplePlatform ? 'Cmd' : 'Meta');
    }
    if (alt) {
      parts.add(_isApplePlatform ? 'Opt' : 'Alt');
    }
    if (shift) {
      parts.add('Shift');
    }

    parts.add(_keyLabel(trigger));

    return parts.join('+');
  }

  /// Returns a short human-readable label for a [LogicalKeyboardKey].
  static String _keyLabel(LogicalKeyboardKey key) {
    // Map well-known keys to concise labels.
    if (key == LogicalKeyboardKey.delete) return 'Del';
    if (key == LogicalKeyboardKey.backspace) return 'Backspace';
    if (key == LogicalKeyboardKey.enter) return 'Enter';
    if (key == LogicalKeyboardKey.escape) return 'Esc';
    if (key == LogicalKeyboardKey.tab) return 'Tab';
    if (key == LogicalKeyboardKey.space) return 'Space';
    if (key == LogicalKeyboardKey.arrowUp) return 'Up';
    if (key == LogicalKeyboardKey.arrowDown) return 'Down';
    if (key == LogicalKeyboardKey.arrowLeft) return 'Left';
    if (key == LogicalKeyboardKey.arrowRight) return 'Right';

    // Fall back to the key label, uppercased for single characters.
    final label = key.keyLabel;
    if (label.length == 1) return label.toUpperCase();
    return label;
  }
}

// ── Shortcut binding ────────────────────────────────────────────────────────

/// A binding between a keyboard shortcut and an action.
///
/// Combines a [ShortcutActivator] with a human-readable [label] and an
/// [onInvoke] callback. An optional [category] groups related shortcuts
/// in the help overlay.
///
/// {@category Composites}
class OiShortcutBinding {
  /// Creates an [OiShortcutBinding].
  const OiShortcutBinding({
    required this.activator,
    required this.label,
    required this.onInvoke,
    this.description,
    this.category,
  });

  /// The keyboard activator that triggers this shortcut.
  final ShortcutActivator activator;

  /// A short human-readable label displayed in the help overlay.
  final String label;

  /// An optional longer description for the help overlay.
  final String? description;

  /// An optional category used to group shortcuts in the help overlay.
  final String? category;

  /// The callback invoked when the shortcut is triggered.
  final VoidCallback onInvoke;
}

// ── Intent / Action glue ────────────────────────────────────────────────────

/// An [Intent] that carries the index of the binding to invoke.
class _OiShortcutIntent extends Intent {
  /// Creates an [_OiShortcutIntent] with the given [index].
  const _OiShortcutIntent(this.index);

  /// The index into the [OiShortcuts.shortcuts] list.
  final int index;
}

/// An [Action] that looks up the binding by index and calls [onInvoke].
class _OiShortcutAction extends Action<_OiShortcutIntent> {
  /// Creates an [_OiShortcutAction] with the given [bindings].
  _OiShortcutAction(this.bindings);

  /// The list of shortcut bindings to dispatch against.
  final List<OiShortcutBinding> bindings;

  @override
  Object? invoke(_OiShortcutIntent intent) {
    bindings[intent.index].onInvoke();
    return null;
  }
}

/// An [Intent] that opens the shortcut help overlay.
class _OiShowHelpIntent extends Intent {
  /// Creates an [_OiShowHelpIntent].
  const _OiShowHelpIntent();
}

/// An [Action] that builds and shows the help overlay.
class _OiShowHelpAction extends Action<_OiShowHelpIntent> {
  /// Creates an [_OiShowHelpAction] with the given [bindings].
  _OiShowHelpAction(this.bindings);

  /// The list of shortcut bindings to display.
  final List<OiShortcutBinding> bindings;

  @override
  Object? invoke(_OiShowHelpIntent intent) {
    // The help overlay is shown by the OiShortcuts widget itself via
    // OverlayEntry. This action just triggers the callback.
    _onShowHelp?.call();
    return null;
  }

  /// External callback wired by [_OiShortcutsState].
  VoidCallback? _onShowHelp;
}

// ── OiShortcuts widget ──────────────────────────────────────────────────────

/// Keyboard shortcut manager with optional help overlay.
///
/// Registers shortcuts globally or per-scope, and shows a "?" help
/// dialog listing all active shortcuts when [showHelpOnQuestionMark] is
/// `true`.
///
/// {@category Composites}
class OiShortcuts extends StatefulWidget {
  /// Creates an [OiShortcuts].
  const OiShortcuts({
    required this.child,
    required this.shortcuts,
    this.showHelpOnQuestionMark = true,
    super.key,
  });

  /// The widget subtree to which shortcuts apply.
  final Widget child;

  /// The list of keyboard shortcut bindings.
  final List<OiShortcutBinding> shortcuts;

  /// Whether pressing `?` (Shift + Slash) opens the help overlay.
  ///
  /// Defaults to `true`.
  final bool showHelpOnQuestionMark;

  @override
  State<OiShortcuts> createState() => _OiShortcutsState();
}

class _OiShortcutsState extends State<OiShortcuts> {
  /// Tracks whether the help overlay is currently visible.
  OverlayEntry? _helpOverlay;

  @override
  void dispose() {
    _removeHelpOverlay();
    super.dispose();
  }

  // ── Help overlay ────────────────────────────────────────────────────────

  /// Shows the help overlay listing all registered shortcuts.
  void _showHelpOverlay() {
    if (_helpOverlay != null) return;

    final entry = OverlayEntry(
      builder: (context) => _OiShortcutHelpOverlay(
        bindings: widget.shortcuts,
        onDismiss: _removeHelpOverlay,
      ),
    );

    Overlay.of(context).insert(entry);
    _helpOverlay = entry;
  }

  /// Removes the help overlay if visible.
  void _removeHelpOverlay() {
    _helpOverlay?.remove();
    _helpOverlay = null;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Build the shortcut → intent map.
    final shortcutMap = <ShortcutActivator, Intent>{};
    for (var i = 0; i < widget.shortcuts.length; i++) {
      shortcutMap[widget.shortcuts[i].activator] = _OiShortcutIntent(i);
    }

    // Wire up the help action callback.
    final helpAction = _OiShowHelpAction(widget.shortcuts)
      .._onShowHelp = _showHelpOverlay;

    // Add "?" shortcut for help if enabled.
    if (widget.showHelpOnQuestionMark) {
      shortcutMap[const SingleActivator(
        LogicalKeyboardKey.slash,
        shift: true,
      )] = const _OiShowHelpIntent();
    }

    return Shortcuts(
      shortcuts: shortcutMap,
      child: Actions(
        actions: <Type, Action<Intent>>{
          _OiShortcutIntent: _OiShortcutAction(widget.shortcuts),
          if (widget.showHelpOnQuestionMark) _OiShowHelpIntent: helpAction,
        },
        child: Focus(
          autofocus: true,
          child: widget.child,
        ),
      ),
    );
  }
}

// ── Help overlay ────────────────────────────────────────────────────────────

/// A full-screen overlay that lists all registered shortcuts grouped by
/// category.
class _OiShortcutHelpOverlay extends StatelessWidget {
  /// Creates an [_OiShortcutHelpOverlay].
  const _OiShortcutHelpOverlay({
    required this.bindings,
    required this.onDismiss,
  });

  /// The shortcut bindings to display.
  final List<OiShortcutBinding> bindings;

  /// Called when the overlay should be dismissed.
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    // Group bindings by category.
    final grouped = <String, List<OiShortcutBinding>>{};
    for (final binding in bindings) {
      final cat = binding.category ?? 'General';
      grouped.putIfAbsent(cat, () => []).add(binding);
    }

    final children = <Widget>[];
    for (final entry in grouped.entries) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            entry.key,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
      for (final binding in entry.value) {
        final activatorLabel = binding.activator is OiShortcutActivator
            ? (binding.activator as OiShortcutActivator).displayLabel
            : binding.activator.toString();
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(activatorLabel),
                ),
                Expanded(child: Text(binding.label)),
              ],
            ),
          ),
        );
      }
      children.add(const SizedBox(height: 12));
    }

    return GestureDetector(
      onTap: onDismiss,
      behavior: HitTestBehavior.opaque,
      child: ColoredBox(
        color: const Color(0x88000000),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Absorb taps on the dialog body.
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Keyboard Shortcuts',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: children,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: onDismiss,
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
