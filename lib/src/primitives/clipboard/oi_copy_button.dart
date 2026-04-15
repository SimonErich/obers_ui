import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_icon_button.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/interaction/oi_touch_target.dart';

/// A tappable button that copies [value] to the system clipboard.
///
/// After tapping, the icon is replaced by a check icon for
/// [feedbackDuration] before reverting to the normal icon.
///
/// By default renders as an [OiIconButton] using [OiIcons.copy] and
/// [OiIcons.check], which provides built-in hover and press states.
///
/// Provide a custom [icon] to opt out of the icon-button styling and render
/// a plain tap target instead (legacy behaviour).
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
  /// When `null`, an [OiIconButton] with [OiIcons.copy] is used which
  /// provides hover and press feedback automatically.
  final Widget? icon;

  /// Widget shown immediately after a copy.
  ///
  /// Defaults to an [OiIcon] rendering [OiIcons.check] (or an [OiIconButton]
  /// when [icon] is also `null`).
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
    // When no custom icon is provided, use OiIconButton for built-in hover.
    if (widget.icon == null && widget.copiedWidget == null) {
      return OiIconButton(
        icon: _copied ? OiIcons.check : OiIcons.copy,
        semanticLabel: widget.semanticLabel,
        onTap: _handleTap,
      );
    }

    // Legacy path: custom icon/copiedWidget — plain tap target.
    final displayWidget = _copied
        ? (widget.copiedWidget ??
              const OiIcon.decorative(icon: OiIcons.check, size: 16))
        : (widget.icon ??
              const OiIcon.decorative(icon: OiIcons.copy, size: 16));

    return OiTouchTarget(
      child: Semantics(
        label: widget.semanticLabel,
        button: true,
        child: GestureDetector(onTap: _handleTap, child: displayWidget),
      ),
    );
  }
}
