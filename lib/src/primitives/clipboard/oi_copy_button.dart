import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/primitives/interaction/oi_touch_target.dart';

/// A tappable button that copies [value] to the system clipboard.
///
/// After tapping, [icon] is replaced by [copiedWidget] (or the default "✓"
/// text) for [feedbackDuration] before reverting to the normal icon.
///
/// Provide a custom [icon] to override the default copy symbol ("⎘").
///
/// **Accessibility (REQ-0014):** [semanticLabel] is required so the button
/// has an accessible description announced by screen readers.
///
/// {@category Primitives}
class OiCopyButton extends StatefulWidget {
  /// Creates an [OiCopyButton].
  const OiCopyButton({
    required this.value,
    required this.semanticLabel,
    this.feedbackDuration = const Duration(milliseconds: 1500),
    this.icon,
    this.copiedWidget,
    super.key,
  });

  /// The text written to the clipboard when the button is tapped.
  final String value;

  /// Accessibility label announced by screen readers.
  final String semanticLabel;

  /// How long to show the "copied" feedback before reverting to the icon.
  ///
  /// Defaults to 1 500 ms.
  final Duration feedbackDuration;

  /// Widget shown when no copy has just been performed.
  ///
  /// Defaults to a [Text] rendering "⎘".
  final Widget? icon;

  /// Widget shown immediately after a copy.
  ///
  /// Defaults to a [Text] rendering "✓".
  final Widget? copiedWidget;

  @override
  State<OiCopyButton> createState() => _OiCopyButtonState();
}

class _OiCopyButtonState extends State<OiCopyButton> {
  bool _copied = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await Clipboard.setData(ClipboardData(text: widget.value));

    if (!mounted) return;
    setState(() => _copied = true);

    _timer?.cancel();
    _timer = Timer(widget.feedbackDuration, () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayWidget = _copied
        ? (widget.copiedWidget ?? const Text('✓'))
        : (widget.icon ?? const Text('⎘'));

    return OiTouchTarget(
      child: Semantics(
        label: widget.semanticLabel,
        button: true,
        child: GestureDetector(onTap: _handleTap, child: displayWidget),
      ),
    );
  }
}
