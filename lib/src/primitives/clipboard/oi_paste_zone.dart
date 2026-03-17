import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Detects a paste keyboard shortcut (Ctrl+V / Cmd+V) within its subtree and
/// calls [onPaste] with the current clipboard text.
///
/// Wrap any widget tree with [OiPasteZone] to react to paste events without
/// needing a text field. When [enabled] is `false` the shortcut is silently
/// ignored.
///
/// ```dart
/// OiPasteZone(
///   onPaste: (text) => setState(() => _pasted = text),
///   child: const Text('focus here, then Ctrl+V'),
/// )
/// ```
///
/// {@category Primitives}
class OiPasteZone extends StatelessWidget {
  /// Creates an [OiPasteZone].
  const OiPasteZone({
    required this.onPaste,
    required this.child,
    this.enabled = true,
    this.autofocus = false,
    super.key,
  });

  /// Called with the pasted text after a paste shortcut is detected.
  final ValueChanged<String> onPaste;

  /// The child widget.
  final Widget child;

  /// Whether paste detection is active.
  ///
  /// When `false`, the Ctrl+V / Cmd+V shortcut is ignored.
  final bool enabled;

  /// Whether to request focus immediately when first built.
  ///
  /// Defaults to `false`. Set to `true` when the paste zone should receive
  /// keyboard events without an explicit focus request.
  final bool autofocus;

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!enabled) return KeyEventResult.ignored;
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final isCtrlOrMeta =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;

    if (isCtrlOrMeta && event.logicalKey == LogicalKeyboardKey.keyV) {
      Clipboard.getData(Clipboard.kTextPlain).then((data) {
        final text = data?.text;
        if (text != null) onPaste(text);
      });
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: autofocus,
      onKeyEvent: _handleKeyEvent,
      child: child,
    );
  }
}
