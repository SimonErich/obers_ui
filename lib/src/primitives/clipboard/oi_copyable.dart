import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Wraps [child] so that the [value] is copied to the system clipboard when
/// the user taps or presses Ctrl+C / Cmd+C.
///
/// When [enabled] is `false` all interaction is suppressed and nothing is
/// copied. [onCopied] is called after a successful copy.
///
/// ```dart
/// OiCopyable(
///   value: 'Hello world',
///   child: const Text('tap to copy'),
/// )
/// ```
///
/// {@category Primitives}
class OiCopyable extends StatelessWidget {
  /// Creates an [OiCopyable].
  const OiCopyable({
    required this.value,
    required this.child,
    this.enabled = true,
    this.onCopied,
    super.key,
  });

  /// The text value written to the clipboard on copy.
  final String value;

  /// The child widget.
  final Widget child;

  /// Whether copying is enabled.
  ///
  /// When `false`, tap and keyboard shortcuts are ignored.
  final bool enabled;

  /// Called after the value has been successfully written to the clipboard.
  final VoidCallback? onCopied;

  Future<void> _copy() async {
    if (!enabled) return;
    await Clipboard.setData(ClipboardData(text: value));
    onCopied?.call();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!enabled) return KeyEventResult.ignored;
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final isCtrlOrMeta = HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;

    if (isCtrlOrMeta && event.logicalKey == LogicalKeyboardKey.keyC) {
      _copy();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: enabled ? _copy : null,
        child: child,
      ),
    );
  }
}
