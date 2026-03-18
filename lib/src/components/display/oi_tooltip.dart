import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/overlay/oi_floating.dart';

/// A tooltip that shows [message] (or rich [content]) near its [child].
///
/// On pointer devices, hovering over [child] after [showDelay] shows the
/// tooltip. On touch devices, long-pressing [child] shows the tooltip and
/// auto-dismisses it after 2 seconds.
///
/// {@category Components}
class OiTooltip extends StatefulWidget {
  /// Creates an [OiTooltip].
  const OiTooltip({
    required this.label,
    required this.message,
    required this.child,
    this.content,
    this.showDelay = const Duration(milliseconds: 600),
    this.alignment = OiFloatingAlignment.topCenter,
    super.key,
  });

  /// The accessible label describing this tooltip for screen readers.
  final String label;

  /// The text message shown in the tooltip.
  ///
  /// Ignored when [content] is provided.
  final String message;

  /// The child widget over which the tooltip is displayed.
  final Widget child;

  /// Optional rich content that overrides [message].
  final Widget? content;

  /// Delay before the tooltip appears after hover/long-press starts.
  final Duration showDelay;

  /// Where the tooltip appears relative to [child].
  final OiFloatingAlignment alignment;

  @override
  State<OiTooltip> createState() => _OiTooltipState();
}

class _OiTooltipState extends State<OiTooltip> {
  bool _visible = false;
  Timer? _showTimer;
  Timer? _dismissTimer;

  @override
  void dispose() {
    _showTimer?.cancel();
    _dismissTimer?.cancel();
    super.dispose();
  }

  void _scheduleShow() {
    _showTimer?.cancel();
    _showTimer = Timer(widget.showDelay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  void _hide() {
    _showTimer?.cancel();
    _dismissTimer?.cancel();
    if (mounted) setState(() => _visible = false);
  }

  void _onLongPress() {
    _showTimer?.cancel();
    if (mounted) setState(() => _visible = true);
    _dismissTimer?.cancel();
    _dismissTimer = Timer(const Duration(seconds: 2), _hide);
  }

  Widget _buildTooltipContent(BuildContext context) {
    final colors = context.colors;
    final body =
        widget.content ??
        Text(
          widget.message,
          style: TextStyle(
            fontSize: 12,
            color: colors.textInverse,
            height: 1.4,
          ),
        );

    return IgnorePointer(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 240),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colors.text.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: colors.overlay.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: body,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final anchor = MouseRegion(
      onEnter: (_) => _scheduleShow(),
      onExit: (_) => _hide(),
      child: GestureDetector(
        onLongPress: _onLongPress,
        behavior: HitTestBehavior.opaque,
        child: widget.child,
      ),
    );

    return Semantics(
      label: widget.label,
      child: OiFloating(
        visible: _visible,
        alignment: widget.alignment,
        anchor: anchor,
        child: _buildTooltipContent(context),
      ),
    );
  }
}
