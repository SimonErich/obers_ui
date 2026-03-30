// Internal widget — no need for public doc comments on private class

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

class OiInputFrame extends StatelessWidget {
  const OiInputFrame({
    required this.child,
    this.label,
    this.hint,
    this.error,
    this.focused = false,
    this.enabled = true,
    this.readOnly = false,
    this.leading,
    this.trailing,
    this.padding,
    this.counter,
    super.key,
  });

  final Widget child;
  final String? label;
  final String? hint;
  final String? error;
  final bool focused;
  final bool enabled;
  final bool readOnly;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  /// Optional counter widget rendered below the input (e.g. "3/50").
  final Widget? counter;

  OiBorderStyle _resolveBorder(BuildContext context) {
    final dec = context.decoration;
    if (error != null && error!.isNotEmpty) {
      return dec.errorBorder;
    }
    if (focused) {
      return dec.focusBorder;
    }
    return dec.defaultBorder;
  }

  @override
  Widget build(BuildContext context) {
    final border = _resolveBorder(context);
    final colors = context.colors;
    final ti = context.components.textInput;
    final anim = context.animations;
    final effectivePadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8);

    final row = Row(
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 8)],
        Expanded(child: child),
        ?trailing,
      ],
    );

    final Color bgColor;
    if (!enabled) {
      bgColor = ti?.disabledBackgroundColor ?? colors.surfaceSubtle;
    } else if (focused) {
      bgColor =
          ti?.focusBackgroundColor ?? ti?.backgroundColor ?? colors.surface;
    } else {
      bgColor = ti?.backgroundColor ?? colors.surface;
    }

    final resolvedRadius =
        border.borderRadius ?? BorderRadius.circular(8);

    final surfaceWidget = _AnimatedInputSurface(
      borderColor: border.color,
      borderWidth: border.width,
      borderRadius: resolvedRadius,
      backgroundColor: bgColor,
      duration: anim.fast,
      curve: Curves.easeOut,
      padding: effectivePadding,
      child: row,
    );

    Widget frame = surfaceWidget;

    if (!enabled) {
      frame = Opacity(opacity: 0.6, child: frame);
    }

    final hasError = error != null && error!.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          OiLabel.smallStrong(label!),
          const SizedBox(height: 4),
        ],
        frame,
        if (hasError) ...[
          const SizedBox(height: 4),
          Semantics(
            liveRegion: true,
            child: Row(
              children: [
                // REQ-0025: error icon so color is never the sole indicator.
                Icon(
                  OiIcons.circleAlert, // error
                  size: 14,
                  color: colors.error.base,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    error!,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.error.base,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else if (hint != null) ...[
          const SizedBox(height: 4),
          Text(
            hint!,
            style: TextStyle(
              fontSize: 12,
              color: colors.textMuted,
              height: 1.3,
            ),
          ),
        ],
        if (counter != null) ...[
          const SizedBox(height: 4),
          Semantics(child: counter),
        ],
      ],
    );
  }
}

/// Implicitly animates border color, width, radius, and background color
/// so that focus/error transitions feel smooth rather than snapping.
class _AnimatedInputSurface extends ImplicitlyAnimatedWidget {
  const _AnimatedInputSurface({
    required this.borderColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.backgroundColor,
    required this.padding,
    required super.duration,
    required super.curve,
    this.child,
  });

  final Color borderColor;
  final double borderWidth;
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final Widget? child;

  @override
  _AnimatedInputSurfaceState createState() => _AnimatedInputSurfaceState();
}

class _AnimatedInputSurfaceState
    extends AnimatedWidgetBaseState<_AnimatedInputSurface> {
  ColorTween? _borderColorTween;
  Tween<double>? _borderWidthTween;
  BorderRadiusTween? _borderRadiusTween;
  ColorTween? _bgColorTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _borderColorTween = visitor(
      _borderColorTween,
      widget.borderColor,
      (dynamic value) => ColorTween(begin: value as Color),
    ) as ColorTween?;
    _borderWidthTween = visitor(
      _borderWidthTween,
      widget.borderWidth,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
    _borderRadiusTween = visitor(
      _borderRadiusTween,
      widget.borderRadius,
      (dynamic value) => BorderRadiusTween(begin: value as BorderRadius),
    ) as BorderRadiusTween?;
    _bgColorTween = visitor(
      _bgColorTween,
      widget.backgroundColor,
      (dynamic value) => ColorTween(begin: value as Color),
    ) as ColorTween?;
  }

  @override
  Widget build(BuildContext context) {
    final color = _borderColorTween?.evaluate(animation) ?? widget.borderColor;
    final width =
        _borderWidthTween?.evaluate(animation) ?? widget.borderWidth;
    final radius =
        _borderRadiusTween?.evaluate(animation) ?? widget.borderRadius;
    final bgColor =
        _bgColorTween?.evaluate(animation) ?? widget.backgroundColor;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: radius,
        border: width > 0
            ? Border.all(color: color, width: width)
            : null,
      ),
      padding: widget.padding,
      child: widget.child,
    );
  }
}
